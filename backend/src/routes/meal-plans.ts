import { Router } from 'express';
import { verifyAccessToken } from '../middlewares/auth';
import { asyncHandler } from '../middlewares/error';
import MealPlansService from '../services/meal-plans.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     MealPlanRequest:
 *       type: object
 *       required:
 *         - week_start_date
 *       properties:
 *         week_start_date:
 *           type: string
 *           format: date
 *         preferences:
 *           type: object
 *     MealPlan:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         user_id:
 *           type: string
 *           format: uuid
 *         week_start_date:
 *           type: string
 *           format: date
 *         created_at:
 *           type: string
 *           format: date-time
 *     MealPlanItem:
 *       type: object
 *       properties:
 *         id:
 *           type: string
 *           format: uuid
 *         meal_plan_id:
 *           type: string
 *           format: uuid
 *         date:
 *           type: string
 *           format: date
 *         meal_slot:
 *           type: string
 *           enum: [BREAKFAST, LUNCH, DINNER, SNACK]
 *         recipe_id:
 *           type: string
 *           format: uuid
 */

const router = Router();

/**
 * @swagger
 * /v1/meal-plans/generate:
 *   post:
 *     summary: Generate meal plan for the week
 *     tags: [Meal Plans]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/MealPlanRequest'
 *     responses:
 *       201:
 *         description: Meal plan generated successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/MealPlan'
 *       401:
 *         description: Unauthorized
 */
router.post('/generate', verifyAccessToken, asyncHandler(MealPlansService.generateMealPlan));

/**
 * @swagger
 * /v1/meal-plans/{id}:
 *   get:
 *     summary: Get meal plan by ID
 *     tags: [Meal Plans]
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
 *         description: Meal plan details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/MealPlan'
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Meal plan not found
 */
router.get('/:id', verifyAccessToken, asyncHandler(MealPlansService.getMealPlan));

/**
 * @swagger
 * /v1/meal-plans/{id}/add-recipe:
 *   patch:
 *     summary: Add recipe to meal plan
 *     tags: [Meal Plans]
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
 *             type: object
 *             required:
 *               - date
 *               - meal_slot
 *               - recipe_id
 *             properties:
 *               date:
 *                 type: string
 *                 format: date
 *               meal_slot:
 *                 type: string
 *                 enum: [BREAKFAST, LUNCH, DINNER, SNACK]
 *               recipe_id:
 *                 type: string
 *                 format: uuid
 *     responses:
 *       200:
 *         description: Recipe added successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Meal plan not found
 */
router.patch('/:id/add-recipe', verifyAccessToken, asyncHandler(MealPlansService.addRecipe));

/**
 * @swagger
 * /v1/meal-plans/{id}/remove-recipe:
 *   delete:
 *     summary: Remove recipe from meal plan
 *     tags: [Meal Plans]
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
 *             type: object
 *             required:
 *               - date
 *               - meal_slot
 *             properties:
 *               date:
 *                 type: string
 *                 format: date
 *               meal_slot:
 *                 type: string
 *                 enum: [BREAKFAST, LUNCH, DINNER, SNACK]
 *     responses:
 *       200:
 *         description: Recipe removed successfully
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: Meal plan not found
 */
router.delete('/:id/remove-recipe', verifyAccessToken, asyncHandler(MealPlansService.removeRecipe));

export default router;
