import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import AdvisoryService from '../services/advisory.service';

const router = Router();

router.post('/check', verifyAccessToken, asyncHandler(AdvisoryService.checkAdvisory));

export default router;
