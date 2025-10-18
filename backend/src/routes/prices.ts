import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import PricesService from '../services/prices.service';

const router = Router();

// Public routes
router.get('/', asyncHandler(PricesService.getPrices));

// Protected routes
router.post('/', verifyAccessToken, requireRole('ADMIN'), asyncHandler(PricesService.createPrice));
router.patch('/:id', verifyAccessToken, requireRole('ADMIN'), asyncHandler(PricesService.updatePrice));
router.delete('/:id', verifyAccessToken, requireRole('ADMIN'), asyncHandler(PricesService.deletePrice));

export default router;
