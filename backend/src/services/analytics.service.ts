import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class AnalyticsService {
  static async getTopRecipes(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get top recipes - TODO' });
  }
}

export default AnalyticsService;
