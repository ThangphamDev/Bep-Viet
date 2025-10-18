import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class ShoppingService {
  static async createFromMealPlan(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Create shopping list from meal plan - TODO' });
  }

  static async getShoppingList(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get shopping list - TODO' });
  }

  static async checkItem(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Check shopping item - TODO' });
  }

  static async exportList(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Export shopping list - TODO' });
  }
}

export default ShoppingService;
