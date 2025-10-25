import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { UpdateProfileDto, UserProfileDto, ChangePasswordDto } from './dto/users.dto';
import * as bcrypt from 'bcryptjs';

@Injectable()
export class UsersService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getProfile(userId: string): Promise<UserProfileDto> {
    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    const [users] = await this.db.execute(
      `SELECT id, email, name, role, region, subregion, created_at 
       FROM users WHERE id = ?`,
      [userId]
    );

    const user = (users as any[])[0];
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async updateProfile(userId: string, updateProfileDto: UpdateProfileDto) {
    const { name, region, subregion, preferences } = updateProfileDto;

    // Update user profile
    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (name !== undefined) {
      updateFields.push('name = ?');
      updateValues.push(name);
    }
    if (region !== undefined) {
      updateFields.push('region = ?');
      updateValues.push(region);
    }
    if (subregion !== undefined) {
      updateFields.push('subregion = ?');
      updateValues.push(subregion);
    }

    if (updateFields.length > 0) {
      updateValues.push(userId);
      await this.db.execute(
        `UPDATE users SET ${updateFields.join(', ')} WHERE id = ?`,
        updateValues
      );
    }

    // Update preferences if provided
    if (preferences) {
      await this.db.execute(
        `UPDATE user_preferences SET 
         household_size = ?, spicy_level = ?, taste_spicy = ?, taste_salty = ?, taste_sweet = ?, taste_light = ?
         WHERE user_id = ?`,
        [
          preferences.household_size || 2,
          preferences.spicy_level || 2,
          preferences.taste_spicy || 2,
          preferences.taste_salty || 2,
          preferences.taste_sweet || 2,
          preferences.taste_light || 2,
          userId,
        ]
      );
    }

    // Get updated user profile
    const updatedUser = await this.getProfile(userId);
    
    return {
      success: true,
      data: updatedUser,
      message: 'Profile updated successfully',
    };
  }

  async getUserById(userId: string): Promise<UserProfileDto> {
    const [users] = await this.db.execute(
      `SELECT id, email, name, role, region, subregion, created_at 
       FROM users WHERE id = ?`,
      [userId]
    );

    const user = (users as any[])[0];
    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  async deleteAccount(userId: string): Promise<void> {
    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    // Check if user exists
    const [users] = await this.db.execute(
      `SELECT id FROM users WHERE id = ?`,
      [userId]
    );

    if (!users || (users as any[]).length === 0) {
      throw new NotFoundException('User not found');
    }

    // Delete moderation_actions that reference this user
    // (moderation_actions doesn't have ON DELETE CASCADE)
    await this.db.execute(
      `DELETE FROM moderation_actions WHERE admin_user_id = ?`,
      [userId]
    );

    // Delete user account
    // Note: CASCADE DELETE is set in the database schema for related records
    // This will automatically delete:
    // - user_preferences
    // - devices
    // - subscriptions
    // - family_profiles & family_members
    // - pantry_items
    // - meal_plan_items
    // - shopping_lists & shopping_list_items
    // - user_recipes
    // - recipe_ratings & comments
    // - user_followers
    // - favorites
    // - notifications
    await this.db.execute(
      `DELETE FROM users WHERE id = ?`,
      [userId]
    );
  }

  async changePassword(userId: string, changePasswordDto: ChangePasswordDto): Promise<void> {
    const { currentPassword, newPassword} = changePasswordDto;

    if (!userId) {
      throw new NotFoundException('User ID is required');
    }

    // Get user with current password
    const [users] = await this.db.execute(
      `SELECT id, password_hash FROM users WHERE id = ?`,
      [userId]
    );

    const user = (users as any[])[0];
    if (!user) {
      throw new NotFoundException('User not found');
    }

    // Verify current password
    const isCurrentPasswordValid = await bcrypt.compare(currentPassword, user.password_hash);
    if (!isCurrentPasswordValid) {
      throw new BadRequestException('Current password is incorrect');
    }

    // Hash new password
    const saltRounds = 12;
    const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

    // Update password
    await this.db.execute(
      `UPDATE users SET password_hash = ? WHERE id = ?`,
      [hashedNewPassword, userId]
    );
  }

  // ============ ADMIN METHODS ============

  async getAllUsers(filters: any = {}) {
    try {
      let query = `
        SELECT 
          u.id,
          u.email,
          u.name,
          u.role,
          u.region,
          u.subregion,
          u.is_active,
          u.created_at,
          u.updated_at,
          COUNT(DISTINCT cr.id) as recipe_count,
          COUNT(DISTINCT s.id) as subscription_count
        FROM users u
        LEFT JOIN community_recipes cr ON u.id = cr.author_user_id
        LEFT JOIN subscriptions s ON u.id = s.user_id AND s.status = 'ACTIVE'
        WHERE 1=1
      `;

      const params: any[] = [];

      if (filters.search) {
        query += ' AND (LOWER(u.name) LIKE LOWER(?) OR LOWER(u.email) LIKE LOWER(?))';
        params.push(`%${filters.search}%`, `%${filters.search}%`);
      }

      if (filters.role) {
        query += ' AND u.role = ?';
        params.push(filters.role);
      }

      if (filters.is_active !== undefined) {
        query += ' AND u.is_active = ?';
        params.push(filters.is_active);
      }

      query += ' GROUP BY u.id ORDER BY u.created_at DESC';

      if (filters.limit) {
        query += ` LIMIT ${parseInt(filters.limit.toString())}`;
      }
      if (filters.offset) {
        query += ` OFFSET ${parseInt(filters.offset.toString())}`;
      }

      const [users] = await this.db.execute(query, params);

      return {
        success: true,
        data: users,
      };
    } catch (error) {
      throw new BadRequestException(`Failed to get users: ${error.message}`);
    }
  }

  async getUserRecipes(userId: string) {
    try {
      const [recipes] = await this.db.execute(
        `SELECT 
          id,
          title,
          region,
          status,
          difficulty,
          time_min,
          image_url,
          created_at,
          updated_at
        FROM community_recipes
        WHERE author_user_id = ?
        ORDER BY created_at DESC`,
        [userId]
      );

      return {
        success: true,
        data: recipes,
      };
    } catch (error) {
      throw new BadRequestException(`Failed to get user recipes: ${error.message}`);
    }
  }

  async blockUser(userId: string, adminUserId: string) {
    try {
      // Check if user exists
      const [users] = await this.db.execute(
        'SELECT id, name, is_active FROM users WHERE id = ?',
        [userId]
      );

      if ((users as any[]).length === 0) {
        throw new NotFoundException('User not found');
      }

      const user = (users as any[])[0];

      if (!user.is_active) {
        throw new BadRequestException('User is already blocked');
      }

      // Block user
      await this.db.execute(
        'UPDATE users SET is_active = 0 WHERE id = ?',
        [userId]
      );

      // Log moderation action
      const [uuidResult] = await this.db.execute('SELECT UUID() as id');
      const actionId = (uuidResult as any[])[0].id;

      await this.db.execute(
        `INSERT INTO moderation_actions (id, target_type, target_id, admin_user_id, action, note)
         VALUES (?, 'USER', ?, ?, 'BLOCK', 'User blocked by admin')`,
        [actionId, userId, adminUserId]
      );

      return {
        success: true,
        message: `User ${user.name} has been blocked`,
      };
    } catch (error) {
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new BadRequestException(`Failed to block user: ${error.message}`);
    }
  }

  async unblockUser(userId: string, adminUserId: string) {
    try {
      // Check if user exists
      const [users] = await this.db.execute(
        'SELECT id, name, is_active FROM users WHERE id = ?',
        [userId]
      );

      if ((users as any[]).length === 0) {
        throw new NotFoundException('User not found');
      }

      const user = (users as any[])[0];

      if (user.is_active) {
        throw new BadRequestException('User is already active');
      }

      // Unblock user
      await this.db.execute(
        'UPDATE users SET is_active = 1 WHERE id = ?',
        [userId]
      );

      // Log moderation action
      const [uuidResult] = await this.db.execute('SELECT UUID() as id');
      const actionId = (uuidResult as any[])[0].id;

      await this.db.execute(
        `INSERT INTO moderation_actions (id, target_type, target_id, admin_user_id, action, note)
         VALUES (?, 'USER', ?, ?, 'UNBLOCK', 'User unblocked by admin')`,
        [actionId, userId, adminUserId]
      );

      return {
        success: true,
        message: `User ${user.name} has been unblocked`,
      };
    } catch (error) {
      if (error instanceof NotFoundException || error instanceof BadRequestException) {
        throw error;
      }
      throw new BadRequestException(`Failed to unblock user: ${error.message}`);
    }
  }
}
