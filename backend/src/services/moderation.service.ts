import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class ModerationService {
  static async approveRecipe(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Approve recipe - TODO' });
  }

  static async rejectRecipe(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Reject recipe - TODO' });
  }

  static async featureRecipe(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Feature recipe - TODO' });
  }
}

export default ModerationService;
