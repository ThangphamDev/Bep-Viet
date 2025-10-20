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

  /**
   * Analyze user intent from prompt using Gemini AI
   */
  private async analyzeUserIntent(prompt: string): Promise<any> {
    try {
      if (!prompt || !this.apiKey) {
        return this.getDefaultIntent();
      }

      const analysisPrompt = `Bạn là chuyên gia phân tích yêu cầu nấu ăn. Phân tích yêu cầu sau: "${prompt}"

Trả về JSON với cấu trúc:
{
  "keywords": ["từ khóa chính được phát hiện"],
  "intent": "baby_food|rich_flavor|light|quick|spicy|low_oil|normal",
  "preferredTags": ["danh sách tags cần ưu tiên"],
  "avoidTags": ["danh sách tags cần tránh"],
  "criteria": {
    "spice_level_max": 1,
    "difficulty_max": 3,
    "cook_time_max": 60
  }
}

Quy tắc phân tích:
- "bé" / "trẻ em" / "em nhỏ" / "con" → intent: "baby_food", preferredTags: ["Cháo", "Súp", "Cho bé ăn", "Hấp", "Luộc", "Mềm nhũn"], avoidTags: ["Chiên", "Cay vừa", "Rất cay"], criteria: {spice_level_max: 0, difficulty_max: 2, cook_time_max: 40}
- "đậm vị" / "đậm đà" / "mặn mà" / "đậm" → intent: "rich_flavor", preferredTags: ["Kho", "Đậm đà", "Món chính"], criteria: {difficulty_max: 4, cook_time_max: 90}
- "nhẹ" / "thanh đạm" / "ít dầu" / "ăn kiêng" → intent: "light", preferredTags: ["Thanh đạm", "Ít dầu mỡ", "Luộc", "Hấp", "Canh"], avoidTags: ["Chiên", "Kho", "Đậm đà"], criteria: {spice_level_max: 2, difficulty_max: 3}
- "nhanh" / "dễ" / "đơn giản" → intent: "quick", preferredTags: ["Nhanh gọn", "Dễ làm", "Xào"], criteria: {difficulty_max: 2, cook_time_max: 25}
- "cay" / "thêm ớt" → intent: "spicy", preferredTags: ["Cay vừa", "Rất cay"], criteria: {spice_level_max: 5}
- "không cay" / "bớt cay" → intent: "low_spice", preferredTags: ["Không cay", "Ít cay"], avoidTags: ["Cay vừa", "Rất cay"], criteria: {spice_level_max: 1}

CHỈ trả về JSON, không giải thích thêm.`;

      const requestBody = {
        contents: [{
          parts: [{ text: analysisPrompt }]
        }]
      };

      const response = await fetch(`${this.apiUrl}?key=${this.apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(requestBody),
      });

      if (!response.ok) {
        this.logger.warn(`Gemini API error for intent analysis: ${response.status}`);
        return this.getDefaultIntent();
      }

      const data = await response.json();
      const textContent = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (!textContent) {
        return this.getDefaultIntent();
      }

      const jsonMatch = textContent.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        this.logger.warn('No JSON found in intent analysis response');
        return this.getDefaultIntent();
      }

      return JSON.parse(jsonMatch[0]);
    } catch (error) {
      this.logger.error('Error analyzing user intent:', error);
      return this.getDefaultIntent();
    }
  }

  /**
   * Get default intent when analysis fails
   */
  private getDefaultIntent(): any {
    return {
      keywords: [],
      intent: 'normal',
      preferredTags: [],
      avoidTags: [],
      criteria: {
        spice_level_max: 5,
        difficulty_max: 5,
        cook_time_max: 120
      }
    };
  }

  /**
   * Calculate request match score based on intent analysis
   */
  private calculateRequestMatchScore(recipe: any, intent: any): number {
    let score = 0.5; // base score

    if (!intent || intent.intent === 'normal') {
      return 0.5;
    }

    const recipeTags = recipe.tag_names ? recipe.tag_names.split(',').map(t => t.trim()) : [];

    // Check preferred tags match (40% weight)
    if (intent.preferredTags && intent.preferredTags.length > 0) {
      const matchedTags = intent.preferredTags.filter(tag => 
        recipeTags.some(rt => rt === tag)
      );
      score += (matchedTags.length / intent.preferredTags.length) * 0.4;
    }

    // Check avoid tags (penalty)
    if (intent.avoidTags && intent.avoidTags.length > 0) {
      const hasAvoidTags = intent.avoidTags.some(tag => 
        recipeTags.some(rt => rt === tag)
      );
      if (hasAvoidTags) {
        score -= 0.3;
      }
    }

    // Check criteria match (30% weight)
    const criteria = intent.criteria || {};
    let criteriaMatches = 0;
    let criteriaTot = 0;

    if (criteria.spice_level_max !== undefined) {
      criteriaTot++;
      if (recipe.spice_level <= criteria.spice_level_max) {
        criteriaMatches++;
      }
    }

    if (criteria.difficulty_max !== undefined) {
      criteriaTot++;
      if (recipe.difficulty <= criteria.difficulty_max) {
        criteriaMatches++;
      }
    }

    if (criteria.cook_time_max !== undefined) {
      criteriaTot++;
      if (recipe.cook_time_min <= criteria.cook_time_max) {
        criteriaMatches++;
      }
    }

    if (criteriaTot > 0) {
      score += (criteriaMatches / criteriaTot) * 0.3;
    }

    return Math.max(0, Math.min(1, score));
  }

  /**
   * Calculate final score combining request match and ingredient match
   */
  private calculateFinalScore(recipe: any, intent: any): number {
    const hasUserRequest = intent && intent.intent !== 'normal';
    const requestMatchScore = this.calculateRequestMatchScore(recipe, intent);
    const ingredientMatchScore = recipe.matched_ingredients / recipe.total_ingredients;

    if (hasUserRequest) {
      // Prioritize user request 70%, ingredients 30%
      return (requestMatchScore * 0.7) + (ingredientMatchScore * 0.3);
    } else {
      // Only ingredient match
      return ingredientMatchScore;
    }
  }

  /**
   * AI-powered recipe suggestions - CHATBOT STYLE
   * Gemini phân tích toàn bộ và trả về response dạng conversation
   */
  async aiSuggestChatbot(params: {
    ingredient_ids: string[];
    prompt?: string;
    region?: string;
    spice_preference?: number;
    limit?: number;
  }): Promise<any> {
    try {
      const { ingredient_ids, prompt, region, spice_preference, limit = 10 } = params;

      if (ingredient_ids.length === 0) {
        return {
          chatResponse: 'Bạn chưa cung cấp nguyên liệu. Hãy chụp ảnh hoặc chọn nguyên liệu nhé!',
          suggestions: [],
          generalAdvice: null
        };
      }

      // 1. Lấy tên nguyên liệu từ DB
      const placeholders = ingredient_ids.map(() => '?').join(',');
      const [dbIngredients] = await this.db.execute(
        `SELECT name FROM ingredients WHERE id IN (${placeholders})`,
        ingredient_ids
      );
      const ingredientNames = (dbIngredients as any[]).map(i => i.name).join(', ');

      // 2. Lấy danh sách recipes (query rộng để Gemini tự chọn)
      let recipeQuery = `
        SELECT 
          r.id, r.name_vi, r.difficulty, r.cook_time_min, 
          r.spice_level, r.base_region, r.meal_type,
          GROUP_CONCAT(DISTINCT t.name ORDER BY t.name SEPARATOR ', ') as tag_names,
          GROUP_CONCAT(DISTINCT i.name ORDER BY i.name SEPARATOR ', ') as ingredient_names
        FROM recipes r
        LEFT JOIN recipe_tags rt ON r.id = rt.recipe_id
        LEFT JOIN tags t ON rt.tag_id = t.id
        LEFT JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN ingredients i ON ri.ingredient_id = i.id
        WHERE r.is_public = 1
      `;
      
      const queryParams: any[] = [];
      if (region) {
        recipeQuery += ' AND r.base_region = ?';
        queryParams.push(region);
      }
      
      recipeQuery += ' GROUP BY r.id LIMIT 50';

      const [recipes] = await this.db.execute(recipeQuery, queryParams);

      // 3. Build Gemini prompt (chatbot style)
      const regionName = region === 'BAC' ? 'Miền Bắc' : region === 'TRUNG' ? 'Miền Trung' : region === 'NAM' ? 'Miền Nam' : 'Việt Nam';
      const spiceLevel = spice_preference === 0 ? 'KHÔNG cay (cho bé/người ăn kiêng)' 
        : spice_preference === 1 ? 'Ít cay' 
        : spice_preference === 2 ? 'Cay vừa' 
        : spice_preference === 3 ? 'Hơi cay' 
        : 'Rất cay';

      const geminiPrompt = `Bạn là chuyên gia ẩm thực Việt Nam, đang tư vấn cho người dùng.

📌 THÔNG TIN NGƯỜI DÙNG:
- Nguyên liệu có sẵn: ${ingredientNames}
- Yêu cầu: "${prompt || 'Không có yêu cầu đặc biệt, gợi ý món ngon'}"
- Khu vực: ${regionName}
- Độ cay mong muốn: ${spiceLevel}

📋 DANH SÁCH CÔNG THỨC CÓ SẴN TRONG HỆ THỐNG:
${(recipes as any[]).map((r, i) => 
  `${i + 1}. ID: ${r.id}
   Tên: ${r.name_vi}
   Tags: ${r.tag_names || 'N/A'}
   Nguyên liệu: ${r.ingredient_names || 'N/A'}
   Độ cay: ${r.spice_level}/5, Độ khó: ${r.difficulty}/5, Thời gian: ${r.cook_time_min} phút`
).join('\n')}

🎯 YÊU CẦU PHÂN TÍCH:

1. **PHÂN TÍCH KỸ YÊU CẦU**: "${prompt || 'món ngon'}"
   - "bé"/"trẻ em"/"em nhỏ"/"con" → Ưu tiên cháo, súp, luộc, hấp. TRÁNH chiên, kho cay, món khó nhai
   - "đậm vị"/"đậm đà"/"mặn mà" → Ưu tiên kho, rim, món có nước mắm/tương đậm
   - "nhẹ"/"thanh đạm"/"ít dầu" → Ưu tiên luộc, hấp, canh, tránh chiên rán
   - "nhanh"/"dễ"/"đơn giản" → Ưu tiên xào, món < 30 phút, độ khó ≤ 2
   - "cay" → Ưu tiên món có ớt, sa tế
   - "không cay" → Chỉ chọn món spice_level = 0

2. **CHỌN 5-7 MÓN PHÙ HỢP NHẤT** theo thứ tự ưu tiên:
   a. Khớp với YÊU CẦU người dùng (ưu tiên CAO NHẤT)
   b. Khớp với nguyên liệu có sẵn
   c. Phù hợp với khu vực địa lý

3. **VỚI MỖI MÓN, TÍNH**:
   - recipeId: ⚠️ BẮT BUỘC PHẢI LẤY ID CHÍNH XÁC từ danh sách (format: uuid dài, VD: "0000819b-35ce-4259-b837-b89fbdb346db")
   - recipeName: Tên món
   - matchReason: TẠI SAO món này phù hợp với yêu cầu "${prompt}" (1 câu ngắn gọn)
   - advisory: Gợi ý điều chỉnh CỤ THỂ dựa vào yêu cầu (thìa/phút/gram)
   - ingredientMatch: % nguyên liệu khớp (0-100)
   - missingIngredients: Danh sách nguyên liệu còn thiếu (tối đa 5)

4. **TẠO CHAT RESPONSE**: Lời giới thiệu thân thiện (2-3 câu), phân tích yêu cầu của người dùng

5. **GENERAL ADVICE**: Lời khuyên chung cho loại món này (1-2 câu)

📊 TRẢ VỀ JSON (CHỈ JSON, KHÔNG GIẢI THÍCH THÊM):
{
  "chatResponse": "Chào bạn! [Phân tích yêu cầu và giới thiệu gợi ý]",
  "suggestions": [
    {
      "recipeId": "0000819b-35ce-4259-b837-b89fbdb346db",  ← ⚠️ PHẢI COPY CHÍNH XÁC UUID TỪ DANH SÁCH!
      "recipeName": "...",
      "matchReason": "...",
      "advisory": "...",
      "ingredientMatch": 95,
      "missingIngredients": ["..."],
      "tags": ["..."]
    }
  ],
  "generalAdvice": "..."
}

💡 CỰC KỲ QUAN TRỌNG:
- ⚠️⚠️⚠️ recipeId PHẢI COPY CHÍNH XÁC UUID từ cột "ID:" trong danh sách (VD: "0000819b-35ce-4259-b837-b89fbdb346db")
- KHÔNG ĐƯỢC dùng số thứ tự (1, 2, 3...) làm recipeId
- Nếu yêu cầu "cho bé ăn", món đầu tiên PHẢI là cháo/súp/hấp, KHÔNG ĐƯỢC là chiên/kho/cay
- Nếu yêu cầu "đậm vị", món đầu tiên PHẢI là kho/rim/món đậm đà
- chatResponse phải tự nhiên như đang tư vấn trực tiếp
- advisory phải CỤ THỂ, đo lường được (ví dụ: "Thêm 2 thìa nước mắm", "Kho thêm 15 phút")
- Ưu tiên yêu cầu người dùng > nguyên liệu
`;

      // 4. Call Gemini API
      if (!this.apiKey) {
        throw new Error('Gemini API key not configured');
      }

      const response = await fetch(`${this.apiUrl}?key=${this.apiKey}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{ parts: [{ text: geminiPrompt }] }]
        })
      });

      if (!response.ok) {
        this.logger.error(`Gemini API error: ${response.status}`);
        throw new Error(`Gemini API error: ${response.status}`);
      }

      const data = await response.json();
      const textContent = data.candidates?.[0]?.content?.parts?.[0]?.text;
      
      if (!textContent) {
        throw new Error('No response from Gemini');
      }

      // 5. Parse JSON from Gemini response
      const jsonMatch = textContent.match(/\{[\s\S]*\}/);
      if (!jsonMatch) {
        this.logger.warn('No JSON found in Gemini response');
        throw new Error('Gemini không trả về JSON hợp lệ');
      }

      const result = JSON.parse(jsonMatch[0]);
      this.logger.log(`Gemini chatbot response: ${result.suggestions?.length || 0} suggestions`);
      
      // Enrich suggestions with full recipe data from DB
      if (result.suggestions && result.suggestions.length > 0) {
        const recipeIds = result.suggestions
          .map(s => s.recipeId)
          .filter(id => id);
        
        if (recipeIds.length > 0) {
          const placeholders = recipeIds.map(() => '?').join(',');
          const [fullRecipes] = await this.db.execute(
            `SELECT 
              r.id, r.name_vi, r.image_url, r.base_region,
              r.difficulty, r.cook_time_min,
              r.spice_level, r.rating_avg
            FROM recipes r
            WHERE r.id IN (${placeholders})`,
            recipeIds
          );
          
          // Merge Gemini data with DB data
          result.suggestions = result.suggestions.map(geminiSugg => {
            const dbRecipe = (fullRecipes as any[]).find(r => r.id === geminiSugg.recipeId);
            if (dbRecipe) {
              return {
                ...geminiSugg,
                image_url: dbRecipe.image_url,
                difficulty: dbRecipe.difficulty,
                cook_time_min: dbRecipe.cook_time_min,
                spice_level: dbRecipe.spice_level,
                rating_avg: dbRecipe.rating_avg,
                base_region: dbRecipe.base_region,
              };
            }
            return geminiSugg;
          });
        }
      }
      
      return result;
    } catch (error) {
      this.logger.error('Error in AI suggest chatbot:', error);
      throw error;
    }
  }

  /**
   * AI-powered recipe suggestions with intelligent filtering (OLD VERSION - keep for fallback)
   */
  async aiSuggest(params: {
    ingredient_ids: string[];
    prompt?: string;
    region?: string;
    spice_preference?: number;
    limit?: number;
  }): Promise<any[]> {
    try {
      const { ingredient_ids, prompt, region, spice_preference, limit = 10 } = params;

      if (ingredient_ids.length === 0) {
        return [];
      }

      // Step 1: Analyze user intent
      const intent = prompt ? await this.analyzeUserIntent(prompt) : this.getDefaultIntent();
      this.logger.log(`User intent analyzed: ${JSON.stringify(intent)}`);

      // Step 2: Build query with tags
      const placeholders = ingredient_ids.map(() => '?').join(',');
      
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
          COUNT(DISTINCT ri2.ingredient_id) as total_ingredients,
          GROUP_CONCAT(DISTINCT t.name SEPARATOR ',') as tag_names
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN recipe_ingredients ri2 ON r.id = ri2.recipe_id
        LEFT JOIN recipe_tags rt ON r.id = rt.recipe_id
        LEFT JOIN tags t ON rt.tag_id = t.id
        WHERE r.is_public = 1 
          AND ri.ingredient_id IN (${placeholders})
      `;

      const params_arr: any[] = [...ingredient_ids];

      // Filter by region
      if (region) {
        query += ' AND r.base_region = ?';
        params_arr.push(region);
      }

      // Filter by spice preference
      if (spice_preference !== undefined) {
        query += ' AND r.spice_level <= ?';
        params_arr.push(spice_preference + 1);
      }

      // Filter by criteria from intent
      if (intent.criteria) {
        if (intent.criteria.spice_level_max !== undefined) {
          query += ' AND r.spice_level <= ?';
          params_arr.push(intent.criteria.spice_level_max);
        }
        if (intent.criteria.difficulty_max !== undefined) {
          query += ' AND r.difficulty <= ?';
          params_arr.push(intent.criteria.difficulty_max);
        }
        if (intent.criteria.cook_time_max !== undefined) {
          query += ' AND r.cook_time_min <= ?';
          params_arr.push(intent.criteria.cook_time_max);
        }
      }

      query += `
        GROUP BY r.id
        HAVING matched_ingredients >= 1
      `;

      // Get all matching recipes first
      const [recipes] = await this.db.execute(query, params_arr);

      // Step 3: Calculate scores and filter
      let scoredRecipes = (recipes as any[]).map(recipe => {
        const requestMatchScore = this.calculateRequestMatchScore(recipe, intent);
        const ingredientMatchScore = recipe.matched_ingredients / recipe.total_ingredients;
        const finalScore = this.calculateFinalScore(recipe, intent);

        return {
          ...recipe,
          requestMatchScore,
          ingredientMatchScore,
          matchScore: finalScore,
          match_percentage: Math.round(ingredientMatchScore * 100),
        };
      });

      // Filter out recipes with avoid tags (hard filter)
      if (intent.avoidTags && intent.avoidTags.length > 0) {
        scoredRecipes = scoredRecipes.filter(recipe => {
          const recipeTags = recipe.tag_names ? recipe.tag_names.split(',').map(t => t.trim()) : [];
          return !intent.avoidTags.some(avoidTag => recipeTags.includes(avoidTag));
        });
      }

      // Sort by final score
      scoredRecipes.sort((a, b) => b.matchScore - a.matchScore);

      // Return top results
      return scoredRecipes.slice(0, limit);
    } catch (error) {
      this.logger.error('Error in AI suggest:', error);
      throw error;
    }
  }
}
