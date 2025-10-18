import { Router } from 'express';
import { verifyAccessToken, requireRole } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import RecipesService from '../services/recipes.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     Recipe:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         title:
 *           type: string
 *         description:
 *           type: string
 *         prep_time:
 *           type: integer
 *         cook_time:
 *           type: integer
 *         servings:
 *           type: integer
 *         difficulty:
 *           type: string
 *           enum: [EASY, MEDIUM, HARD]
 *         cuisine_type:
 *           type: string
 *         created_at:
 *           type: string
 *           format: date-time
 *     CreateRecipe:
 *       type: object
 *       required:
 *         - title
 *         - description
 *       properties:
 *         title:
 *           type: string
 *         description:
 *           type: string
 *         prep_time:
 *           type: integer
 *         cook_time:
 *           type: integer
 *         servings:
 *           type: integer
 *         difficulty:
 *           type: string
 *           enum: [EASY, MEDIUM, HARD]
 *         cuisine_type:
 *           type: string
 */

const router = Router();

/**
 * @swagger
 * /v1/recipes:
 *   get:
 *     summary: Get all recipes
 *     tags: [Recipes]
 *     responses:
 *       200:
 *         description: List of recipes
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
 *                     $ref: '#/components/schemas/Recipe'
 */
router.get('/', asyncHandler(RecipesService.getRecipes));

/**
 * @swagger
 * /v1/recipes/{id}:
 *   get:
 *     summary: Get recipe by ID
 *     tags: [Recipes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Recipe details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/Recipe'
 *       404:
 *         description: Recipe not found
 */
router.get('/:id', asyncHandler(RecipesService.getRecipeById));

/**
 * @swagger
 * /v1/recipes:
 *   post:
 *     summary: Create new recipe
 *     tags: [Recipes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreateRecipe'
 *     responses:
 *       201:
 *         description: Recipe created successfully
 *       401:
 *         description: Unauthorized
 */
router.post('/', verifyAccessToken, requireRole(['USER', 'ADMIN']), asyncHandler(RecipesService.createRecipe));

/**
 * @swagger
 * /v1/recipes/{id}:
 *   patch:
 *     summary: Update recipe
 *     tags: [Recipes]
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
 *             $ref: '#/components/schemas/CreateRecipe'
 *     responses:
 *       200:
 *         description: Recipe updated successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Recipe not found
 */
router.patch('/:id', verifyAccessToken, requireRole(['USER', 'ADMIN']), asyncHandler(RecipesService.updateRecipe));

/**
 * @swagger
 * /v1/recipes/{id}:
 *   delete:
 *     summary: Delete recipe
 *     tags: [Recipes]
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
 *         description: Recipe deleted successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Recipe not found
 */
router.delete('/:id', verifyAccessToken, requireRole(['USER', 'ADMIN']), asyncHandler(RecipesService.deleteRecipe));

export default router;
