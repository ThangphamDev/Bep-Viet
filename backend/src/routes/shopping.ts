import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import ShoppingService from '../services/shopping.service';

const router = Router();

router.post('/from-meal-plan', verifyAccessToken, asyncHandler(ShoppingService.createFromMealPlan));
router.get('/:id', verifyAccessToken, asyncHandler(ShoppingService.getShoppingList));
router.patch('/:id/check-item', verifyAccessToken, asyncHandler(ShoppingService.checkItem));
router.get('/:id/export', verifyAccessToken, asyncHandler(ShoppingService.exportList));

export default router;
