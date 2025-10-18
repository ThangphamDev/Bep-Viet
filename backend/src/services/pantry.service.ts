import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class PantryService {
  static async getPantryItems(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get pantry items - TODO' });
  }

  static async addPantryItem(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Add pantry item - TODO' });
  }

  static async updatePantryItem(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Update pantry item - TODO' });
  }

  static async deletePantryItem(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Delete pantry item - TODO' });
  }

  static async consumeItems(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Consume pantry items - TODO' });
  }
}

export default PantryService;
