import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { UpdateProfileDto, UserProfileDto } from './dto/users.dto';

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

    return {
      success: true,
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
}
