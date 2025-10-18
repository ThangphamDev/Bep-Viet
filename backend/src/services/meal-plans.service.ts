import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class MealPlansService {
  static async generateMealPlan(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Generate meal plan - TODO' });
  }

  static async getMealPlan(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get meal plan - TODO' });
  }

  static async addRecipe(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Add recipe to meal plan - TODO' });
  }

  static async removeRecipe(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Remove recipe from meal plan - TODO' });
  }
}

export default MealPlansService;
