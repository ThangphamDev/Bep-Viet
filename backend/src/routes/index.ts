import { Router } from 'express';
import authRoutes from './auth';
import usersRoutes from './users';
import regionsRoutes from './regions';
import seasonsRoutes from './seasons';
import ingredientsRoutes from './ingredients';
import pricesRoutes from './prices';
import recipesRoutes from './recipes';
import suggestionsRoutes from './suggestions';
import mealPlansRoutes from './meal-plans';
import shoppingRoutes from './shopping';
import pantryRoutes from './pantry';
import subscriptionsRoutes from './subscriptions';
import familyRoutes from './family';
import advisoryRoutes from './advisory';
import communityRoutes from './community';
import moderationRoutes from './moderation';
import analyticsRoutes from './analytics';

const router = Router();

// Health check
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Bếp Việt API is running',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
  });
});

// API routes
router.use('/auth', authRoutes);
router.use('/users', usersRoutes);
router.use('/regions', regionsRoutes);
router.use('/seasons', seasonsRoutes);
router.use('/ingredients', ingredientsRoutes);
router.use('/ingredient-prices', pricesRoutes);
router.use('/recipes', recipesRoutes);
router.use('/suggestions', suggestionsRoutes);
router.use('/meal-plans', mealPlansRoutes);
router.use('/shopping-lists', shoppingRoutes);
router.use('/pantry', pantryRoutes);
router.use('/subscriptions', subscriptionsRoutes);
router.use('/family', familyRoutes);
router.use('/advisory', advisoryRoutes);
router.use('/community', communityRoutes);
router.use('/moderation', moderationRoutes);
router.use('/analytics', analyticsRoutes);

export default router;
