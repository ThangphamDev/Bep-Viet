import { Request, Response } from 'express';
import Joi from 'joi';
import { pool } from '../config/db';
import { AppError } from '../middlewares/error';
import { AuthRequest } from '../middlewares/auth';
import logger from '../config/logger';

// Validation schemas
const updateProfileSchema = Joi.object({
  name: Joi.string().min(2).max(255).optional(),
  region: Joi.string().valid('BAC', 'TRUNG', 'NAM').optional(),
  subregion: Joi.string().max(100).optional(),
  household_size: Joi.number().min(1).max(20).optional(),
  spicy_level: Joi.number().min(0).max(5).optional(),
  taste_spicy: Joi.number().min(0).max(5).optional(),
  taste_salty: Joi.number().min(0).max(5).optional(),
  taste_sweet: Joi.number().min(0).max(5).optional(),
  taste_light: Joi.number().min(0).max(5).optional(),
});

class UsersService {
  static async getProfile(req: AuthRequest, res: Response): Promise<void> {
    const userId = req.user!.id;

    // Get user with preferences
    const [users] = await pool.execute(
      `SELECT u.id, u.email, u.name, u.region, u.subregion, u.role, u.created_at,
              up.household_size, up.spicy_level, up.taste_spicy, up.taste_salty, 
              up.taste_sweet, up.taste_light, up.diet_json, up.allergies_json
       FROM users u
       LEFT JOIN user_preferences up ON u.id = up.user_id
       WHERE u.id = ?`,
      [userId]
    );

    const user = (users as any[])[0];

    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          region: user.region,
          subregion: user.subregion,
          role: user.role,
          createdAt: user.created_at,
          preferences: {
            householdSize: user.household_size,
            spicyLevel: user.spicy_level,
            tasteSpicy: user.taste_spicy,
            tasteSalty: user.taste_salty,
            tasteSweet: user.taste_sweet,
            tasteLight: user.taste_light,
            diet: user.diet_json ? JSON.parse(user.diet_json) : null,
            allergies: user.allergies_json ? JSON.parse(user.allergies_json) : null,
          },
        },
      },
    });
  }

  static async updateProfile(req: AuthRequest, res: Response): Promise<void> {
    const userId = req.user!.id;
    const { error, value } = updateProfileSchema.validate(req.body);
    
    if (error) {
      throw new AppError('Validation error', 400, 'VALIDATION_ERROR', error.details);
    }

    const {
      name,
      region,
      subregion,
      household_size,
      spicy_level,
      taste_spicy,
      taste_salty,
      taste_sweet,
      taste_light,
    } = value;

    // Start transaction
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    try {
      // Update user table
      const userUpdates: string[] = [];
      const userValues: any[] = [];

      if (name !== undefined) {
        userUpdates.push('name = ?');
        userValues.push(name);
      }
      if (region !== undefined) {
        userUpdates.push('region = ?');
        userValues.push(region);
      }
      if (subregion !== undefined) {
        userUpdates.push('subregion = ?');
        userValues.push(subregion);
      }

      if (userUpdates.length > 0) {
        userValues.push(userId);
        await connection.execute(
          `UPDATE users SET ${userUpdates.join(', ')} WHERE id = ?`,
          userValues
        );
      }

      // Update user preferences
      const prefUpdates: string[] = [];
      const prefValues: any[] = [];

      if (household_size !== undefined) {
        prefUpdates.push('household_size = ?');
        prefValues.push(household_size);
      }
      if (spicy_level !== undefined) {
        prefUpdates.push('spicy_level = ?');
        prefValues.push(spicy_level);
      }
      if (taste_spicy !== undefined) {
        prefUpdates.push('taste_spicy = ?');
        prefValues.push(taste_spicy);
      }
      if (taste_salty !== undefined) {
        prefUpdates.push('taste_salty = ?');
        prefValues.push(taste_salty);
      }
      if (taste_sweet !== undefined) {
        prefUpdates.push('taste_sweet = ?');
        prefValues.push(taste_sweet);
      }
      if (taste_light !== undefined) {
        prefUpdates.push('taste_light = ?');
        prefValues.push(taste_light);
      }

      if (prefUpdates.length > 0) {
        prefValues.push(userId);
        await connection.execute(
          `UPDATE user_preferences SET ${prefUpdates.join(', ')} WHERE user_id = ?`,
          prefValues
        );
      }

      await connection.commit();

      logger.info('User profile updated successfully', { userId, updates: value });

      res.json({
        success: true,
        message: 'Profile updated successfully',
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  }

  static async getUserById(req: Request, res: Response): Promise<void> {
    const { id } = req.params;

    const [users] = await pool.execute(
      `SELECT u.id, u.email, u.name, u.region, u.subregion, u.role, u.is_active, u.created_at,
              up.household_size, up.spicy_level, up.taste_spicy, up.taste_salty, 
              up.taste_sweet, up.taste_light
       FROM users u
       LEFT JOIN user_preferences up ON u.id = up.user_id
       WHERE u.id = ?`,
      [id]
    );

    const user = (users as any[])[0];

    if (!user) {
      throw new AppError('User not found', 404, 'USER_NOT_FOUND');
    }

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          name: user.name,
          region: user.region,
          subregion: user.subregion,
          role: user.role,
          isActive: user.is_active,
          createdAt: user.created_at,
          preferences: {
            householdSize: user.household_size,
            spicyLevel: user.spicy_level,
            tasteSpicy: user.taste_spicy,
            tasteSalty: user.taste_salty,
            tasteSweet: user.taste_sweet,
            tasteLight: user.taste_light,
          },
        },
      },
    });
  }
}

export default UsersService;
