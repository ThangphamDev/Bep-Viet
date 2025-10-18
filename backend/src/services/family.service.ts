import { Request, Response } from 'express';
import { AuthRequest } from '../middlewares/auth';

class FamilyService {
  static async getFamilyProfiles(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Get family profiles - TODO' });
  }

  static async createFamilyProfile(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Create family profile - TODO' });
  }

  static async addFamilyMember(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Add family member - TODO' });
  }

  static async updateFamilyMember(req: AuthRequest, res: Response): Promise<void> {
    res.json({ success: true, message: 'Update family member - TODO' });
  }
}

export default FamilyService;
