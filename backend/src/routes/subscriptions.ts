import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import SubscriptionsService from '../services/subscriptions.service';

const router = Router();

router.get('/my', verifyAccessToken, asyncHandler(SubscriptionsService.getMySubscription));
router.post('/checkout', verifyAccessToken, asyncHandler(SubscriptionsService.checkout));

export default router;
