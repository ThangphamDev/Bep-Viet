import { Request, Response } from 'express';
import Joi from 'joi';
import { pool } from '../config/db';
import { AppError } from '../middlewares/error';
import {
  hashPassword,
  comparePassword,
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
  generateId,
  validateEmail,
  validatePassword,
} from '../utils/crypto';
import logger from '../config/logger';

// Validation schemas
const registerSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().min(8).required(),
  name: Joi.string().min(2).max(255).required(),
  region: Joi.string().valid('BAC', 'TRUNG', 'NAM').optional(),
  subregion: Joi.string().max(100).optional(),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

const refreshSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

class AuthService {
  static async register(req: Request, res: Response): Promise<void> {
    const { error, value } = registerSchema.validate(req.body);
    
    if (error) {
      throw new AppError('Validation error', 400, 'VALIDATION_ERROR', error.details);
    }

    const { email, password, name, region, subregion } = value;

    // Validate email format
    if (!validateEmail(email)) {
      throw new AppError('Invalid email format', 400, 'INVALID_EMAIL');
    }

    // Validate password strength
    const passwordValidation = validatePassword(password);
    if (!passwordValidation.isValid) {
      throw new AppError('Password validation failed', 400, 'WEAK_PASSWORD', passwordValidation.errors);
    }

    // Check if user already exists
    const [existingUsers] = await pool.execute(
      'SELECT id FROM users WHERE email = ?',
      [email]
    );

    if ((existingUsers as any[]).length > 0) {
      throw new AppError('User already exists', 409, 'USER_EXISTS');
    }

    // Hash password
    const passwordHash = await hashPassword(password);
    const userId = generateId();

    // Create user
    await pool.execute(
      `INSERT INTO users (id, email, password_hash, name, region, subregion, role, is_active)
       VALUES (?, ?, ?, ?, ?, ?, 'USER', 1)`,
      [userId, email, passwordHash, name, region || null, subregion || null]
    );

    // Create user preferences
    await pool.execute(
      `INSERT INTO user_preferences (user_id, household_size, spicy_level, taste_spicy, taste_salty, taste_sweet, taste_light)
       VALUES (?, 2, 2, 2, 2, 2, 2)`,
      [userId]
    );

    // Generate tokens
    const accessToken = generateAccessToken(userId, email, 'USER');
    const refreshToken = generateRefreshToken(userId, email, 'USER');

    logger.info('User registered successfully', { userId, email });

    res.status(201).json({
      success: true,
      data: {
        user: {
          id: userId,
          email,
          name,
          region,
          subregion,
          role: 'USER',
        },
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  }

  static async login(req: Request, res: Response): Promise<void> {
    const { error, value } = loginSchema.validate(req.body);
    
    if (error) {
      throw new AppError('Validation error', 400, 'VALIDATION_ERROR', error.details);
    }

    const { email, password } = value;

    // Find user
    const [users] = await pool.execute(
      'SELECT id, email, password_hash, name, region, subregion, role, is_active FROM users WHERE email = ?',
      [email]
    );

    const user = (users as any[])[0];

    if (!user) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
    }

    if (!user.is_active) {
      throw new AppError('Account is deactivated', 401, 'ACCOUNT_DEACTIVATED');
    }

    // Verify password
    const isPasswordValid = await comparePassword(password, user.password_hash);
    
    if (!isPasswordValid) {
      throw new AppError('Invalid credentials', 401, 'INVALID_CREDENTIALS');
    }

    // Generate tokens
    const accessToken = generateAccessToken(user.id, user.email, user.role);
    const refreshToken = generateRefreshToken(user.id, user.email, user.role);

    logger.info('User logged in successfully', { userId: user.id, email });

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
        },
        tokens: {
          accessToken,
          refreshToken,
        },
      },
    });
  }

  static async refresh(req: Request, res: Response): Promise<void> {
    const { error, value } = refreshSchema.validate(req.body);
    
    if (error) {
      throw new AppError('Validation error', 400, 'VALIDATION_ERROR', error.details);
    }

    const { refreshToken } = value;

    try {
      // Verify refresh token
      const decoded = verifyRefreshToken(refreshToken);
      
      if (decoded.type !== 'refresh') {
        throw new AppError('Invalid token type', 401, 'INVALID_TOKEN');
      }

      // Check if user still exists and is active
      const [users] = await pool.execute(
        'SELECT id, email, role, is_active FROM users WHERE id = ?',
        [decoded.userId]
      );

      const user = (users as any[])[0];
      
      if (!user || !user.is_active) {
        throw new AppError('User not found or inactive', 401, 'USER_INACTIVE');
      }

      // Generate new tokens
      const newAccessToken = generateAccessToken(user.id, user.email, user.role);
      const newRefreshToken = generateRefreshToken(user.id, user.email, user.role);

      res.json({
        success: true,
        data: {
          tokens: {
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          },
        },
      });
    } catch (error) {
      throw new AppError('Invalid refresh token', 401, 'INVALID_REFRESH_TOKEN');
    }
  }

  static async logout(_req: Request, res: Response): Promise<void> {
    // In a real application, you might want to blacklist the token
    // For now, we'll just return success
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  }
}

export default AuthService;
