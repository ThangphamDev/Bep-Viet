import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import FamilyService from '../services/family.service';

const router = Router();

router.get('/', verifyAccessToken, asyncHandler(FamilyService.getFamilyProfiles));
router.post('/', verifyAccessToken, asyncHandler(FamilyService.createFamilyProfile));
router.post('/members', verifyAccessToken, asyncHandler(FamilyService.addFamilyMember));
router.patch('/members/:id', verifyAccessToken, asyncHandler(FamilyService.updateFamilyMember));

export default router;
