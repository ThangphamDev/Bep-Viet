import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import IngredientsService from '../services/ingredients.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     Ingredient:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         name:
 *           type: string
 *         default_unit:
 *           type: string
 *         shelf_life_days:
 *           type: integer
 *         perishable:
 *           type: boolean
 *         notes:
 *           type: string
 *         category_name:
 *           type: string
 *         created_at:
 *           type: string
 *           format: date-time
 *     CreateIngredient:
 *       type: object
 *       required:
 *         - name
 *       properties:
 *         name:
 *           type: string
 *         default_unit:
 *           type: string
 *         shelf_life_days:
 *           type: integer
 *         perishable:
 *           type: boolean
 *         notes:
 *           type: string
 *         category_id:
 *           type: integer
 */

const router = Router();

/**
 * @swagger
 * /v1/ingredients:
 *   get:
 *     summary: Get all ingredients
 *     tags: [Ingredients]
 *     responses:
 *       200:
 *         description: List of ingredients
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
 *                     $ref: '#/components/schemas/Ingredient'
 */
router.get('/', asyncHandler(IngredientsService.getIngredients));

/**
 * @swagger
 * /v1/ingredients/{id}:
 *   get:
 *     summary: Get ingredient by ID
 *     tags: [Ingredients]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Ingredient details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/Ingredient'
 *       404:
 *         description: Ingredient not found
 */
router.get('/:id', asyncHandler(IngredientsService.getIngredientById));

/**
 * @swagger
 * /v1/ingredients:
 *   post:
 *     summary: Create new ingredient (Admin only)
 *     tags: [Ingredients]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateIngredient'
 *     responses:
 *       201:
 *         description: Ingredient created successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin role required
 */
router.post('/', verifyAccessToken, requireRole('ADMIN'), asyncHandler(IngredientsService.createIngredient));

/**
 * @swagger
 * /v1/ingredients/{id}:
 *   patch:
 *     summary: Update ingredient (Admin only)
 *     tags: [Ingredients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateIngredient'
 *     responses:
 *       200:
 *         description: Ingredient updated successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin role required
 *       404:
 *         description: Ingredient not found
 */
router.patch('/:id', verifyAccessToken, requireRole('ADMIN'), asyncHandler(IngredientsService.updateIngredient));

/**
 * @swagger
 * /v1/ingredients/{id}:
 *   delete:
 *     summary: Delete ingredient (Admin only)
 *     tags: [Ingredients]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Ingredient deleted successfully
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden - Admin role required
 *       404:
 *         description: Ingredient not found
 */
router.delete('/:id', verifyAccessToken, requireRole('ADMIN'), asyncHandler(IngredientsService.deleteIngredient));

export default router;
