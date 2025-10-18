import { Router } from 'express';
import { asyncHandler } from '../middlewares/error';
import SuggestionsService from '../services/suggestions.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     SuggestionRequest:
 *       type: object
 *       properties:
 *         region:
 *           type: string
 *         season:
 *           type: string
 *         servings:
 *           type: integer
 *         budget:
 *           type: number
 *         max_cooking_time:
 *           type: integer
 *         allergens:
 *           type: array
 *           items:
 *             type: string
 *         spice_level:
 *           type: integer
 *           minimum: 0
 *           maximum: 5
 *     Suggestion:
 *       type: object
 *       properties:
 *         recipe_id:
 *           type: string
 *         title:
 *           type: string
 *         score:
 *           type: number
 *         reason:
 *           type: string
 */

const router = Router();

/**
 * @swagger
 * /v1/suggestions/search:
 *   post:
 *     summary: Get recipe suggestions based on criteria
 *     tags: [Suggestions]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/SuggestionRequest'
 *     responses:
 *       200:
 *         description: Recipe suggestions
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
 *                     $ref: '#/components/schemas/Suggestion'
 */
router.post('/search', asyncHandler(SuggestionsService.search));

export default router;
