import { Request, Response } from 'express';
import { pool } from '../config/db';

class IngredientsService {
  static async getIngredients(req: Request, res: Response): Promise<void> {
    try {
      // Simple query for now
      const [ingredients] = await pool.execute(
        `SELECT i.id, i.name, i.default_unit, i.shelf_life_days, i.perishable, i.notes, i.created_at,
                ic.name as category_name
         FROM ingredients i
         LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
         ORDER BY i.name
         LIMIT 20`
      );

      res.json({
        success: true,
        data: ingredients,
        pagination: {
          page: 1,
          limit: 20,
          total: (ingredients as any[]).length,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        },
      });
    } catch (error) {
      console.error('Error getting ingredients:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to get ingredients',
        },
      });
    }
  }

  static async getIngredientById(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      
      const [ingredients] = await pool.execute(
        `SELECT i.id, i.name, i.default_unit, i.shelf_life_days, i.perishable, i.notes, i.created_at,
                ic.name as category_name
         FROM ingredients i
         LEFT JOIN ingredient_categories ic ON i.category_id = ic.id
         WHERE i.id = ?`,
        [id]
      );

      if ((ingredients as any[]).length === 0) {
        res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: 'Ingredient not found',
          },
        });
        return;
      }

      res.json({
        success: true,
        data: (ingredients as any[])[0],
      });
    } catch (error) {
      console.error('Error getting ingredient:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to get ingredient',
        },
      });
    }
  }

  static async createIngredient(req: Request, res: Response): Promise<void> {
    try {
      const { name, default_unit, shelf_life_days, perishable, notes, category_id } = req.body;
      
      const [result] = await pool.execute(
        `INSERT INTO ingredients (id, name, default_unit, shelf_life_days, perishable, notes, category_id)
         VALUES (UUID(), ?, ?, ?, ?, ?, ?)`,
        [name, default_unit, shelf_life_days, perishable, notes, category_id]
      );

      res.status(201).json({
        success: true,
        data: { id: (result as any).insertId },
        message: 'Ingredient created successfully',
      });
    } catch (error) {
      console.error('Error creating ingredient:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create ingredient',
        },
      });
    }
  }

  static async updateIngredient(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const { name, default_unit, shelf_life_days, perishable, notes, category_id } = req.body;
      
      const [result] = await pool.execute(
        `UPDATE ingredients 
         SET name = ?, default_unit = ?, shelf_life_days = ?, perishable = ?, notes = ?, category_id = ?
         WHERE id = ?`,
        [name, default_unit, shelf_life_days, perishable, notes, category_id, id]
      );

      if ((result as any).affectedRows === 0) {
        res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: 'Ingredient not found',
          },
        });
        return;
      }

      res.json({
        success: true,
        message: 'Ingredient updated successfully',
      });
    } catch (error) {
      console.error('Error updating ingredient:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to update ingredient',
        },
      });
    }
  }

  static async deleteIngredient(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      
      const [result] = await pool.execute(
        `DELETE FROM ingredients WHERE id = ?`,
        [id]
      );

      if ((result as any).affectedRows === 0) {
        res.status(404).json({
          success: false,
          error: {
            code: 'NOT_FOUND',
            message: 'Ingredient not found',
          },
        });
        return;
      }

      res.json({
        success: true,
        message: 'Ingredient deleted successfully',
      });
    } catch (error) {
      console.error('Error deleting ingredient:', error);
      res.status(500).json({
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to delete ingredient',
        },
      });
    }
  }
}

export default IngredientsService;