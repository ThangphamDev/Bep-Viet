import { Router } from 'express';
import { asyncHandler } from '../middlewares/error';
import SeasonsService from '../services/seasons.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     Season:
 *       type: object
 *       properties:
 *         code:
 *           type: string
 *         name:
 *           type: string
 *         description:
 *           type: string
 *         start_month:
 *           type: integer
 *         end_month:
 *           type: integer
 */

const router = Router();

/**
 * @swagger
 * /v1/seasons:
 *   get:
 *     summary: Get all seasons
 *     tags: [Seasons]
 *     responses:
 *       200:
 *         description: List of seasons
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Season'
 */
router.get('/', asyncHandler(SeasonsService.getSeasons));

export default router;
