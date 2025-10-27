import { Injectable, Logger } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { RedisService } from '../redis/redis.service';
import * as crypto from 'crypto';

@Injectable()
export class SuggestionsService {
  private readonly logger = new Logger(SuggestionsService.name);
  private readonly CACHE_TTL = 300; // 5 minutes

  constructor(
    @Inject('DATABASE_CONNECTION') private db: any,
    private redisService: RedisService,
  ) {}

  /**
   * Generate cache key from search parameters
   */
  private generateCacheKey(params: any): string {
    const normalized = {
      region: params.region || 'all',
      season: params.season || 'auto',
      servings: params.servings || 2,
      budget: params.budget || 'all',
      spice_preference: params.spice_preference || 'all',
      pantry_ids: (params.pantry_ids || []).sort().join(','),
      exclude_allergens: (params.exclude_allergens || []).sort().join(','),
      max_time: params.max_time || 'all',
      meal_type: params.meal_type || 'all',
    };
    
    const keyString = JSON.stringify(normalized);
    const hash = crypto.createHash('md5').update(keyString).digest('hex');
    return `suggestions:${hash}`;
  }

  async searchSuggestions(searchParams: any) {
    try {
      // Generate cache key
      const cacheKey = this.generateCacheKey(searchParams);

      // Try to get from cache
      if (this.redisService.isReady()) {
        const cachedResult = await this.redisService.getJson(cacheKey);
        if (cachedResult) {
          this.logger.log(`Cache HIT for key: ${cacheKey}`);
          return cachedResult;
        }
        this.logger.log(`Cache MISS for key: ${cacheKey}`);
      }

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
    // IMPROVEMENT: Only show recipes with servings <= user's desired servings
    // This ensures we don't suggest a 10-person dish when user wants 1-2 servings
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
        AND COALESCE(r.servings, 2) <= ?
    `;
    
    let params: any[] = [servings]; // First param: max servings

    if (meal_type) {
      query += ' AND r.meal_type = ?';
      params.push(meal_type);
    }

    if (max_time) {
      query += ' AND r.cook_time_min <= ?';
      params.push(max_time);
    }

    // Remove spice filter - let users decide based on recipe info
    // if (spice_preference !== undefined) {
    //   query += ' AND r.spice_level <= ?';
    //   params.push(spice_preference);
    // }

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

      // Allow recipes within budget or up to 20% over budget for flexibility
      const maxBudget = budget ? budget * 1.2 : Infinity;
      if (suggestion.total_cost <= maxBudget || !budget) {
        suggestions.push(suggestion);
      }
    }

    // Sort by final score
    suggestions.sort((a, b) => b.final_score - a.final_score);

    const result = {
      success: true,
      data: suggestions.slice(0, 20), // Return top 20
      cached: false,
    };

    // Save to cache
    if (this.redisService.isReady()) {
      await this.redisService.setJson(cacheKey, result, this.CACHE_TTL);
      this.logger.log(`Cached result for key: ${cacheKey}`);
    }

    return result;
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

    // Use default region 'NAM' for price lookup if region is empty/'all'
    const priceRegion = region && region !== '' && region !== 'all' ? region : 'NAM';

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
      [priceRegion, priceRegion, season, recipe.recipe_id]
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
      
      // Calculate cost with proper scaling
      // If recipe is for 2 people and user wants 4, scale by 2x (4/2)
      const baseQuantity = ingredient.quantity || 1;
      const recipeServings = recipe.servings || 2;
      const scaleFactor = servings / recipeServings;
      const quantity = baseQuantity * scaleFactor;
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

    // Filter out null/undefined ingredient IDs and ensure they are valid
    const pantryIds = (pantryItems as any[])
      .map(item => item.ingredient_id)
      .filter(id => id != null);

    if (pantryIds.length === 0) {
      return {
        success: true,
        data: [],
        message: 'Không có nguyên liệu trong tủ lạnh'
      };
    }

    // Find recipes that use pantry ingredients
    // Simplified query to avoid sort memory issues
    const placeholders = pantryIds.map(() => '?').join(',');
    const query = 
      'SELECT ' +
      '  r.id as recipe_id, ' +
      '  r.name_vi, ' +
      '  r.name_en, ' +
      '  r.meal_type, ' +
      '  r.difficulty, ' +
      '  r.cook_time_min, ' +
      '  r.spice_level, ' +
      '  r.rating_avg, ' +
      '  r.image_url, ' +
      '  COUNT(ri.ingredient_id) as pantry_match_count ' +
      'FROM recipes r ' +
      'JOIN recipe_ingredients ri ON r.id = ri.recipe_id ' +
      'WHERE r.is_public = 1 AND ri.ingredient_id IN (' + placeholders + ') ' +
      'GROUP BY r.id ' +
      'HAVING pantry_match_count >= 2 ' +
      'ORDER BY pantry_match_count DESC, r.rating_avg DESC ' +
      'LIMIT ?';
    
    // Ensure limit is a number, but keep ingredient_ids as-is (they might be strings/UUIDs)
    const safeLimit = Number(limit) || 10;
    const params = [...pantryIds, safeLimit];
    
    // Use query() instead of execute() for dynamic queries
    const [recipes] = await this.db.query(query, params);

    return {
      success: true,
      data: recipes,
      pantry_items: pantryItems
    };
  }
}