import { Request, Response } from 'express';
import { pool } from '../config/db';

class RecipesService {
  static async getRecipes(_req: Request, res: Response): Promise<void> {
    // TODO: Implement filtering by region, budget, difficulty, tag
    // const { region, budget, difficulty, tag } = _req.query;
    
    const [recipes] = await pool.execute(
      `SELECT r.id, r.name_vi, r.name_en, r.meal_type, r.difficulty, r.cook_time_min, 
              r.region, r.base_region, r.spice_level, r.image_url, r.rating_avg, r.rating_count
       FROM recipes r
       WHERE r.is_public = 1
       ORDER BY r.rating_avg DESC, r.created_at DESC
       LIMIT 20`
    );

    res.json({
      success: true,
      data: {
        recipes: recipes as any[],
      },
    });
  }

  static async getRecipeById(_req: Request, res: Response): Promise<void> {
    const { id } = _req.params;

    const [recipes] = await pool.execute(
      `SELECT r.*, u.name as author_name
       FROM recipes r
       LEFT JOIN users u ON r.author_id = u.id
       WHERE r.id = ?`,
      [id]
    );

    const recipe = (recipes as any[])[0];

    if (!recipe) {
      res.status(404).json({
        success: false,
        error: { code: 'RECIPE_NOT_FOUND', message: 'Recipe not found' },
      });
      return;
    }

    res.json({
      success: true,
      data: { recipe },
    });
  }

  static async createRecipe(_req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Create recipe - TODO' });
  }

  static async updateRecipe(_req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Update recipe - TODO' });
  }

  static async deleteRecipe(_req: Request, res: Response): Promise<void> {
    res.json({ success: true, message: 'Delete recipe - TODO' });
  }
}

export default RecipesService;
