import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class AdvisoryService {
  static async checkAdvisory(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Check advisory - TODO' });
  }
}

export default AdvisoryService;
