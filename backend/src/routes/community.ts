import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import CommunityService from '../services/community.service';

const router = Router();

router.get('/recipes', asyncHandler(CommunityService.getCommunityRecipes));
router.post('/recipes', verifyAccessToken, asyncHandler(CommunityService.createCommunityRecipe));
router.get('/recipes/:id', asyncHandler(CommunityService.getCommunityRecipe));
router.post('/recipes/:id/comments', verifyAccessToken, asyncHandler(CommunityService.addComment));
router.post('/recipes/:id/ratings', verifyAccessToken, asyncHandler(CommunityService.addRating));
router.post('/recipes/:id/favorite', verifyAccessToken, asyncHandler(CommunityService.toggleFavorite));

export default router;
