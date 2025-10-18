import { Request, Response } from 'express';
import Joi from 'joi';
import { pool } from '../config/db';
import { AppError } from '../middlewares/error';

// Validation schema
const searchSchema = Joi.object({
  region: Joi.string().valid('BAC', 'TRUNG', 'NAM').optional(),
  season: Joi.string().valid('XUAN', 'HA', 'THU', 'DONG').optional(),
  servings: Joi.number().min(1).max(20).default(2),
  budget: Joi.number().min(0).default(50000),
  pantry_ids: Joi.array().items(Joi.string()).default([]),
  exclude_allergens: Joi.array().items(Joi.string()).default([]),
  spice_pref: Joi.number().min(0).max(5).default(2),
  max_time: Joi.number().min(0).max(300).default(45),
});

class SuggestionsService {
  static async search(_req: Request, res: Response): Promise<void> {
    const { error, value } = searchSchema.validate(_req.body);
    
    if (error) {
      throw new AppError('Validation error', 400, 'VALIDATION_ERROR', error.details);
    }

    const {
      region,
      season,
      servings,
      budget,
      pantry_ids,
      exclude_allergens,
      spice_pref,
      max_time,
    } = value;

    // Get recipes with variants for the specified region
    const [recipes] = await pool.execute(
      `SELECT r.id, r.name_vi, r.name_en, r.difficulty, r.cook_time_min, r.spice_level, 
              r.base_region, r.rating_avg, r.image_url,
              rv.id as variant_id, rv.title as variant_title, rv.notes as variant_notes
       FROM recipes r
       LEFT JOIN recipe_variants rv ON r.id = rv.recipe_id AND rv.region = ?
       WHERE r.is_public = 1
       ORDER BY r.rating_avg DESC
       LIMIT 20`,
      [region || 'NAM']
    );

    const suggestions: any[] = [];

    for (const recipe of recipes as any[]) {
      // Calculate score based on various factors
      let score = recipe.rating_avg * 20; // Base score from rating

      // Time penalty
      if (recipe.cook_time_min > max_time) {
        score -= 20;
      }

      // Spice preference penalty
      const spiceDiff = Math.abs((recipe.spice_level || 0) - spice_pref);
      score -= spiceDiff * 2;

      // Region bonus
      if (recipe.base_region === region) {
        score += 10;
      }

      // Season bonus (simplified)
      if (season) {
        score += 5; // Placeholder for season calculation
      }

      // Budget consideration (simplified)
      const estimatedCost = Math.random() * budget; // Placeholder
      if (estimatedCost <= budget) {
        score += 15;
      } else {
        score -= Math.max(0, (estimatedCost - budget) / 5000);
      }

      suggestions.push({
        recipe_id: recipe.id,
        variant_region: region || 'NAM',
        total_cost: Math.round(estimatedCost),
        season_score: 80, // Placeholder
        score: Math.round(score),
        reason: 'region/season/budget',
        recipe: {
          id: recipe.id,
          name_vi: recipe.name_vi,
          name_en: recipe.name_en,
          difficulty: recipe.difficulty,
          cook_time_min: recipe.cook_time_min,
          spice_level: recipe.spice_level,
          image_url: recipe.image_url,
          rating_avg: recipe.rating_avg,
        },
        items: [], // Placeholder for ingredient items
      });
    }

    // Sort by score descending
    suggestions.sort((a, b) => b.score - a.score);

    res.json({
      success: true,
      data: {
        suggestions: suggestions.slice(0, 10),
        filters: {
          region,
          season,
          servings,
          budget,
          spice_pref,
          max_time,
        },
      },
    });
  }
}

export default SuggestionsService;
