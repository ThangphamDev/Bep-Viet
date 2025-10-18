import { Router } from 'express';
import { asyncHandler } from '../middlewares/error';
import RegionsService from '../services/regions.service';

/**
 * @swagger
 * components:
 *   schemas:
 *     Region:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         code:
 *           type: string
 *         description:
 *           type: string
 *     Subregion:
 *       type: object
 *       properties:
 *         id:
 *           type: integer
 *         name:
 *           type: string
 *         code:
 *           type: string
 *         region_id:
 *           type: integer
 */

const router = Router();

/**
 * @swagger
 * /v1/regions:
 *   get:
 *     summary: Get all regions
 *     tags: [Regions]
 *     responses:
 *       200:
 *         description: List of regions
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
 *                     $ref: '#/components/schemas/Region'
 */
router.get('/', asyncHandler(RegionsService.getRegions));

/**
 * @swagger
 * /v1/regions/{id}/subregions:
 *   get:
 *     summary: Get subregions by region ID
 *     tags: [Regions]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: List of subregions
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
 *                     $ref: '#/components/schemas/Subregion'
 */
router.get('/:id/subregions', asyncHandler(RegionsService.getSubregions));

export default router;
