import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import UsersService from '../services/users.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     UserProfile:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         email:
 *           type: string
 *           format: email
 *         name:
 *           type: string
 *         role:
 *           type: string
 *           enum: [USER, ADMIN]
 *         created_at:
 *           type: string
 *           format: date-time
 *     UpdateProfile:
 *       type: object
 *       properties:
 *         name:
 *           type: string
 *         preferences:
 *           type: object
 */

const router = Router();

/**
 * @swagger
 * /v1/users/me:
 *   get:
 *     summary: Get current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/UserProfile'
 *       401:
 *         description: Unauthorized
 */
router.get('/me', verifyAccessToken, asyncHandler(UsersService.getProfile));

/**
 * @swagger
 * /v1/users/me:
 *   patch:
 *     summary: Update current user profile
 *     tags: [Users]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/UpdateProfile'
 *     responses:
 *       200:
 *         description: Profile updated successfully
 *       401:
 *         description: Unauthorized
 */
router.patch('/me', verifyAccessToken, asyncHandler(UsersService.updateProfile));

// Admin routes
router.get('/:id', verifyAccessToken, requireRole('ADMIN'), asyncHandler(UsersService.getUserById));

export default router;
