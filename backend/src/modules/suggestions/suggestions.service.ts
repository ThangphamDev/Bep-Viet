import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class SuggestionsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async searchSuggestions(searchParams: any) {
    try {
      const {
        region,
        season,
        servings = 2,
        budget,
        spice_preference,
        pantry_ids = [],
        exclude_allergens = [],
        max_time,
        meal_type
      } = searchParams;

    // Get current season if not provided
    let currentSeason = season;
    if (!currentSeason) {
      const currentMonth = new Date().getMonth() + 1;
      const [seasons] = await this.db.execute(
        'SELECT code FROM seasons WHERE FIND_IN_SET(?, months_set) > 0',
        [currentMonth]
      );
      currentSeason = (seasons as any[])[0]?.code || 'HA';
    }

    // Build base query for recipes
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
        r.saltiness,
        r.hardness,
        r.rating_avg,
        r.rating_count,
        r.image_url,
        COALESCE(r.servings, 2) as servings
      FROM recipes r
      WHERE r.is_public = 1
    `;
    
    let params: any[] = [];

    if (meal_type) {
      query += ' AND r.meal_type = ?';
      params.push(meal_type);
    }

    if (max_time) {
      query += ' AND r.cook_time_min <= ?';
      params.push(max_time);
    }

    if (spice_preference !== undefined) {
      query += ' AND r.spice_level <= ?';
      params.push(spice_preference);
    }

    query += ' ORDER BY r.rating_avg DESC, r.created_at DESC LIMIT 50';

    const [recipes] = await this.db.execute(query, params);

    // Calculate scores for each recipe
    const suggestions: any[] = [];
    
    for (const recipe of recipes as any[]) {
      const suggestion = await this.calculateRecipeScore(recipe, {
        region,
        season: currentSeason,
        servings,
        budget,
        pantry_ids,
        exclude_allergens
      });

      if (suggestion.total_cost <= budget || !budget) {
        suggestions.push(suggestion);
      }
    }

    // Sort by final score
    suggestions.sort((a, b) => b.final_score - a.final_score);

    return {
      success: true,
      data: suggestions.slice(0, 20), // Return top 20
    };
    } catch (error) {
      console.error('SuggestionsService error:', error);
      return {
        success: false,
        error: error.message,
        data: []
      };
    }
  }

  private async calculateRecipeScore(recipe: any, params: any) {
    const { region, season, servings, budget, pantry_ids, exclude_allergens } = params;

    // Get recipe ingredients with prices
    const [ingredients] = await this.db.execute(
      `SELECT 
        ri.ingredient_id,
        i.name as ingredient_name,
        ri.quantity,
        ri.unit,
        ip.price_per_unit,
        ip.currency,
        ise.availability_percent,
        ise.price_index
      FROM recipe_ingredients ri
      JOIN ingredients i ON ri.ingredient_id = i.id
      LEFT JOIN ingredient_prices ip ON ri.ingredient_id = ip.ingredient_id AND ip.region = ?
      LEFT JOIN ingredient_seasonality ise ON ri.ingredient_id = ise.ingredient_id 
        AND ise.region = ? AND ise.season_code = ?
      WHERE ri.recipe_id = ?`,
      [region, region, season, recipe.recipe_id]
    );

    let totalCost = 0;
    let seasonScore = 0;
    let pantryBonus = 0;
    let regionBonus = 0;
    let baseScore = recipe.rating_avg * 20; // Convert rating to 0-100 scale

    const items: any[] = [];
    let ingredientCount = 0;

    for (const ingredient of ingredients as any[]) {
      ingredientCount++;
      
      // Calculate cost
      const quantity = ingredient.quantity * servings;
      const cost = ingredient.price_per_unit ? quantity * ingredient.price_per_unit : 0;
      totalCost += cost;

      // Season score
      if (ingredient.availability_percent) {
        seasonScore += ingredient.availability_percent;
      } else {
        seasonScore += 50; // Default if no season data
      }

      // Pantry bonus
      if (pantry_ids && pantry_ids.includes(ingredient.ingredient_id)) {
        pantryBonus += cost; // Reduce cost if already in pantry
      }

      // Region bonus
      if (recipe.base_region === region) {
        regionBonus += 10;
      }

      items.push({
        ingredient_id: ingredient.ingredient_id,
        ingredient_name: ingredient.ingredient_name,
        quantity: quantity,
        unit: ingredient.unit,
        est_cost: cost,
        currency: ingredient.currency || 'VND'
      });
    }

    // Calculate final score
    const avgSeasonScore = seasonScore / ingredientCount;
    const budgetScore = budget ? Math.max(0, 100 - ((totalCost - budget) / budget * 100)) : 100;
    const pantryScore = pantryBonus > 0 ? Math.min(50, pantryBonus / 1000) : 0; // Max 50 points bonus
    
    const finalScore = baseScore + avgSeasonScore + budgetScore + pantryScore + regionBonus;

    return {
      recipe_id: recipe.recipe_id,
      name_vi: recipe.name_vi,
      name_en: recipe.name_en,
      meal_type: recipe.meal_type,
      difficulty: recipe.difficulty,
      cook_time_min: recipe.cook_time_min,
      spice_level: recipe.spice_level,
      saltiness: recipe.saltiness,
      hardness: recipe.hardness,
      rating_avg: recipe.rating_avg,
      rating_count: recipe.rating_count,
      image_url: recipe.image_url,
      servings: recipe.servings || servings || 2,
      variant_region: region,
      total_cost: Math.round(totalCost),
      season_score: Math.round(avgSeasonScore),
      final_score: Math.round(finalScore),
      items: items,
      reason: this.generateReason(recipe, avgSeasonScore, budgetScore, pantryScore, regionBonus)
    };
  }

  private generateReason(recipe: any, seasonScore: number, budgetScore: number, pantryScore: number, regionBonus: number): string {
    const reasons: string[] = [];
    
    if (recipe.base_region) {
      reasons.push('Đúng vùng miền');
    }
    
    if (seasonScore > 80) {
      reasons.push('Đúng mùa vụ');
    }
    
    if (budgetScore > 80) {
      reasons.push('Trong ngân sách');
    }
    
    if (pantryScore > 0) {
      reasons.push('Có sẵn nguyên liệu');
    }
    
    if (recipe.rating_avg > 4) {
      reasons.push('Được đánh giá cao');
    }

    return reasons.length > 0 ? reasons.join(', ') : 'Món ăn phù hợp';
  }

  async getSuggestionsByPantry(userId: string, limit: number = 10) {
    // Get user's pantry items
    const [pantryItems] = await this.db.execute(
      `SELECT 
        pi.ingredient_id,
        i.name as ingredient_name,
        pi.quantity,
        pi.unit,
        pi.expire_date
      FROM pantry_items pi
      JOIN ingredients i ON pi.ingredient_id = i.id
      WHERE pi.user_id = ? AND pi.quantity > 0
      ORDER BY pi.expire_date ASC`,
      [userId]
    );

    const pantryIds = (pantryItems as any[]).map(item => item.ingredient_id);

    if (pantryIds.length === 0) {
      return {
        success: true,
        data: [],
        message: 'Không có nguyên liệu trong tủ lạnh'
      };
    }

    // Find recipes that use pantry ingredients
    const [recipes] = await this.db.execute(
      `SELECT DISTINCT
        r.id as recipe_id,
        r.name_vi,
        r.name_en,
        r.meal_type,
        r.difficulty,
        r.cook_time_min,
        r.spice_level,
        r.rating_avg,
        r.image_url,
        COUNT(ri.ingredient_id) as pantry_match_count,
        COUNT(DISTINCT ri.ingredient_id) as total_ingredients
      FROM recipes r
      JOIN recipe_ingredients ri ON r.id = ri.recipe_id
      WHERE r.is_public = 1 AND ri.ingredient_id IN (${pantryIds.map(() => '?').join(',')})
      GROUP BY r.id
      HAVING pantry_match_count >= 2
      ORDER BY pantry_match_count DESC, r.rating_avg DESC
      LIMIT ?`,
      [...pantryIds, limit]
    );

    return {
      success: true,
      data: recipes,
      pantry_items: pantryItems
    };
  }
}