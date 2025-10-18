import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import AnalyticsService from '../services/analytics.service';

const router = Router();

router.get('/recipes/top', verifyAccessToken, requireRole('ADMIN'), asyncHandler(AnalyticsService.getTopRecipes));

export default router;
