import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import PantryService from '../services/pantry.service';

const router = Router();

router.get('/', verifyAccessToken, asyncHandler(PantryService.getPantryItems));
router.post('/', verifyAccessToken, asyncHandler(PantryService.addPantryItem));
router.patch('/:id', verifyAccessToken, asyncHandler(PantryService.updatePantryItem));
router.delete('/:id', verifyAccessToken, asyncHandler(PantryService.deletePantryItem));
router.post('/consume', verifyAccessToken, asyncHandler(PantryService.consumeItems));

export default router;
