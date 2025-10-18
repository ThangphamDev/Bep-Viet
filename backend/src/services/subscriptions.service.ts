import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class SubscriptionsService {
  static async getMySubscription(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get my subscription - TODO' });
  }

  static async checkout(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Checkout subscription - TODO' });
  }
}

export default SubscriptionsService;
