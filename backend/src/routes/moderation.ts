import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import ModerationService from '../services/moderation.service';

const router = Router();

router.post('/recipes/:id/approve', verifyAccessToken, requireRole('ADMIN'), asyncHandler(ModerationService.approveRecipe));
router.post('/recipes/:id/reject', verifyAccessToken, requireRole('ADMIN'), asyncHandler(ModerationService.rejectRecipe));
router.post('/recipes/:id/feature', verifyAccessToken, requireRole('ADMIN'), asyncHandler(ModerationService.featureRecipe));

export default router;
