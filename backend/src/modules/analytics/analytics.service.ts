import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class AnalyticsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getUserAnalytics(userId: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    const [stats] = await this.db.execute(
      `SELECT 
        COUNT(DISTINCT mp.id) as meal_plans_count,
        COUNT(DISTINCT pi.id) as pantry_items_count,
        COUNT(DISTINCT sl.id) as shopping_lists_count,
        COUNT(DISTINCT cr.id) as community_recipes_count,
        COUNT(DISTINCT rr.id) as ratings_given_count
      FROM users u
      LEFT JOIN meal_plans mp ON u.id = mp.user_id
      LEFT JOIN pantry_items pi ON u.id = pi.user_id
      LEFT JOIN shopping_lists sl ON u.id = sl.owner_id
      LEFT JOIN community_recipes cr ON u.id = cr.author_user_id
      LEFT JOIN recipe_ratings rr ON u.id = rr.user_id
      WHERE u.id = ?`,
      [userId]
    );

    return {
      success: true,
      data: (stats as any[])[0],
    };
  }

  async getSystemAnalytics() {
    const [stats] = await this.db.execute(
      `SELECT 
        COUNT(DISTINCT u.id) as total_users,
        COUNT(DISTINCT r.id) as total_recipes,
        COUNT(DISTINCT cr.id) as total_community_recipes,
        COUNT(DISTINCT rr.id) as total_ratings,
        COUNT(DISTINCT mp.id) as total_meal_plans
      FROM users u
      LEFT JOIN recipes r ON 1=1
      LEFT JOIN community_recipes cr ON 1=1
      LEFT JOIN recipe_ratings rr ON 1=1
      LEFT JOIN meal_plans mp ON 1=1`
    );

    return {
      success: true,
      data: (stats as any[])[0],
    };
  }
}
