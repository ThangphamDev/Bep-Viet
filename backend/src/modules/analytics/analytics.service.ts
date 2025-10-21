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
    // Use separate queries to avoid Cartesian product
    const [userCount] = await this.db.execute('SELECT COUNT(*) as count FROM users');
    const [recipeCount] = await this.db.execute('SELECT COUNT(*) as count FROM recipes');
    const [communityRecipeCount] = await this.db.execute('SELECT COUNT(*) as count FROM community_recipes');
    const [ratingCount] = await this.db.execute('SELECT COUNT(*) as count FROM recipe_ratings');
    const [mealPlanCount] = await this.db.execute('SELECT COUNT(*) as count FROM meal_plans');
    const [ingredientCount] = await this.db.execute('SELECT COUNT(*) as count FROM ingredients');
    const [pantryItemCount] = await this.db.execute('SELECT COUNT(*) as count FROM pantry_items');
    const [shoppingListCount] = await this.db.execute('SELECT COUNT(*) as count FROM shopping_lists');

    // Get top recipes
    const [topRecipes] = await this.db.execute(
      `SELECT r.id, r.name_vi as name, COALESCE(r.rating_avg, 0) as rating_avg, r.rating_count
       FROM recipes r
       WHERE r.rating_count > 0
       ORDER BY r.rating_avg DESC, r.rating_count DESC
       LIMIT 5`
    );

    // Get recent activity
    const [recentActivity] = await this.db.execute(
      `SELECT 
        'community_recipe' as type,
        cr.id,
        cr.title as name,
        cr.created_at,
        u.name as user_name
       FROM community_recipes cr
       JOIN users u ON cr.author_user_id = u.id
       ORDER BY cr.created_at DESC
       LIMIT 10`
    );

    return {
      success: true,
      data: {
        total_users: (userCount as any[])[0].count,
        total_recipes: (recipeCount as any[])[0].count,
        total_community_recipes: (communityRecipeCount as any[])[0].count,
        total_ratings: (ratingCount as any[])[0].count,
        total_meal_plans: (mealPlanCount as any[])[0].count,
        total_ingredients: (ingredientCount as any[])[0].count,
        total_pantry_items: (pantryItemCount as any[])[0].count,
        total_shopping_lists: (shoppingListCount as any[])[0].count,
        top_recipes: topRecipes,
        recent_activity: recentActivity
      },
    };
  }
}
