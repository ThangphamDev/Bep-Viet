import { Injectable, Logger, Inject } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface IngredientMatch {
  name: string;
  confidence: number;
  category?: string;
  matched_id?: string;
}

export interface GeminiAnalysisResult {
  ingredients: IngredientMatch[];
  suggestions: string[];
  raw_response?: string;
}

@Injectable()
export class GeminiService {
  private readonly logger = new Logger(GeminiService.name);
  private readonly apiKey: string;
  private readonly apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';

  constructor(
    private configService: ConfigService,
    @Inject('DATABASE_CONNECTION') private db: any,
  ) {
    this.apiKey = this.configService.get<string>('GEMINI_API_KEY') || '';
    if (!this.apiKey) {
      this.logger.warn('GEMINI_API_KEY not configured');
    }
  }

  /**
   * Analyze image to detect ingredients using Gemini 2.0 Flash Exp
   */
  async analyzeIngredients(imageBase64: string): Promise<GeminiAnalysisResult> {
    try {
      if (!this.apiKey) {
        throw new Error('Gemini API key not configured');
      }

      // Get all ingredients from database for better matching
      const [dbIngredients] = await this.db.execute(
        'SELECT id, name FROM ingredients LIMIT 500'
      );
      
      const ingredientList = (dbIngredients as any[])
        .map(i => i.name)
        .join(', ');

      const prompt = `Bạn là chuyên gia nhận diện nguyên liệu nấu ăn Việt Nam. 
Hãy phân tích hình ảnh và xác định các nguyên liệu có trong ảnh.

Danh sách nguyên liệu trong database: ${ingredientList}

Yêu cầu:
1. Nhận diện TẤT CẢ nguyên liệu thấy được trong ảnh
2. Với mỗi nguyên liệu, hãy cho:
   - Tên nguyên liệu (tiếng Việt)
   - Độ tin cậy (0-100%)
   - Phân loại (rau, thịt, hải sản, gia vị, v.v.)
3. Đề xuất 2-3 món ăn Việt Nam có thể nấu với các nguyên liệu này

Trả về kết quả dưới dạng JSON với cấu trúc:
{
  "ingredients": [
    {"name": "tên nguyên liệu", "confidence": 95, "category": "loại"}
  ],
  "suggestions": ["món 1", "món 2", "món 3"]
}`;

      const requestBody = {
        contents: [{
          parts: [
            { text: prompt },
            {
              inline_data: {
                mime_type: 'image/jpeg',
                data: imageBase64
              }
            }
          ]
        }]
      };

      this.logger.log('Calling Gemini API for ingredient analysis...');

      const response = await fetch(`${this.apiUrl}?key=${this.apiKey}`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        const errorText = await response.text();
        this.logger.error(`Gemini API error: ${response.status} - ${errorText}`);
        throw new Error(`Gemini API error: ${response.status}`);
      }

      const data = await response.json();
      
      if (!data.candidates || data.candidates.length === 0) {
        throw new Error('No response from Gemini API');
      }

      const textContent = data.candidates[0].content.parts[0].text;
      this.logger.log('Received response from Gemini API');

      // Parse JSON from response
      const jsonMatch = textContent.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        this.logger.warn('No JSON found in response, returning raw text');
        return {
          ingredients: [],
          suggestions: [],
          raw_response: textContent,
        };
      }

      const parsed = JSON.parse(jsonMatch[0]);
      
      // Match ingredients with database
      const matchedIngredients = await this.matchIngredientsWithDB(parsed.ingredients);

      return {
        ingredients: matchedIngredients,
        suggestions: parsed.suggestions || [],
        raw_response: textContent,
      };
    } catch (error) {
      this.logger.error('Error analyzing ingredients:', error);
      throw error;
    }
  }

  /**
   * Match detected ingredients with database ingredients
   */
  private async matchIngredientsWithDB(
    detectedIngredients: IngredientMatch[]
  ): Promise<IngredientMatch[]> {
    const matched: IngredientMatch[] = [];

    for (const ingredient of detectedIngredients) {
      try {
        // Try exact match first
        const [exactMatch] = await this.db.execute(
          'SELECT id, name FROM ingredients WHERE LOWER(name) = LOWER(?)',
          [ingredient.name]
        );

        if ((exactMatch as any[]).length > 0) {
          matched.push({
            ...ingredient,
            matched_id: (exactMatch as any[])[0].id,
            name: (exactMatch as any[])[0].name,
          });
          continue;
        }

        // Try fuzzy match with aliases
        const [aliasMatch] = await this.db.execute(
          `SELECT i.id, i.name 
           FROM ingredients i
           LEFT JOIN ingredient_aliases ia ON i.id = ia.ingredient_id
           WHERE LOWER(i.name) LIKE LOWER(?) OR LOWER(ia.alias) LIKE LOWER(?)
           LIMIT 1`,
          [`%${ingredient.name}%`, `%${ingredient.name}%`]
        );

        if ((aliasMatch as any[]).length > 0) {
          matched.push({
            ...ingredient,
            matched_id: (aliasMatch as any[])[0].id,
            name: (aliasMatch as any[])[0].name,
          });
        } else {
          // Keep unmatched ingredient
          matched.push(ingredient);
        }
      } catch (error) {
        this.logger.error(`Error matching ingredient ${ingredient.name}:`, error);
        matched.push(ingredient);
      }
    }

    return matched;
  }

  /**
   * Get recipe suggestions based on detected ingredients
   */
  async getSuggestionsFromIngredients(
    ingredientIds: string[],
    region?: string,
    limit: number = 10
  ): Promise<any[]> {
    try {
      if (ingredientIds.length === 0) {
        return [];
      }

      const placeholders = ingredientIds.map(() => '?').join(',');
      
      let query = `
        SELECT 
          r.id as recipe_id,
          r.name_vi,
          r.name_en,
          r.meal_type,
          r.difficulty,
          r.cook_time_min,
          r.base_region,
          r.spice_level,
          r.rating_avg,
          r.rating_count,
          r.image_url,
          COUNT(DISTINCT ri.ingredient_id) as matched_ingredients,
          COUNT(DISTINCT ri2.ingredient_id) as total_ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN recipe_ingredients ri2 ON r.id = ri2.recipe_id
        WHERE r.is_public = 1 
          AND ri.ingredient_id IN (${placeholders})
      `;

      const params: any[] = [...ingredientIds];

      if (region) {
        query += ' AND r.base_region = ?';
        params.push(region);
      }

      query += `
        GROUP BY r.id
        HAVING matched_ingredients >= 2
        ORDER BY matched_ingredients DESC, r.rating_avg DESC
        LIMIT ?
      `;
      
      params.push(limit);

      const [recipes] = await this.db.execute(query, params);

      return (recipes as any[]).map(recipe => ({
        ...recipe,
        match_percentage: Math.round(
          (recipe.matched_ingredients / recipe.total_ingredients) * 100
        ),
      }));
    } catch (error) {
      this.logger.error('Error getting suggestions from ingredients:', error);
      throw error;
    }
  }
}
