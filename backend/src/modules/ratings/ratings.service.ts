import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class RatingsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getRecipeRatings(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', limit: number = 20, offset: number = 0) {
    const [ratings] = await this.db.execute(
      `SELECT 
        rr.id,
        rr.stars,
        rr.created_at,
        rr.updated_at,
        u.id as user_id,
        u.name as user_name,
        u.role as user_role
      FROM recipe_ratings rr
      JOIN users u ON rr.user_id = u.id
      WHERE rr.recipe_id = ? AND rr.recipe_type = ?
      ORDER BY rr.created_at DESC
      LIMIT ? OFFSET ?`,
      [recipeId, recipeType, limit, offset]
    );

    const [totalCount] = await this.db.execute(
      'SELECT COUNT(*) as total FROM recipe_ratings WHERE recipe_id = ? AND recipe_type = ?',
      [recipeId, recipeType]
    );

    const [avgRating] = await this.db.execute(
      'SELECT AVG(stars) as average, COUNT(*) as count FROM recipe_ratings WHERE recipe_id = ? AND recipe_type = ?',
      [recipeId, recipeType]
    );

    return {
      success: true,
      data: {
        ratings,
        statistics: {
          average: parseFloat((avgRating as any[])[0].average || 0).toFixed(1),
          count: (totalCount as any[])[0].total,
          distribution: await this.getRatingDistribution(recipeId, recipeType)
        },
        pagination: {
          total: (totalCount as any[])[0].total,
          limit,
          offset,
          has_more: (totalCount as any[])[0].total > offset + limit
        }
      }
    };
  }

  async addRating(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', userId: string, stars: number) {
    const [result] = await this.db.execute(
      `INSERT INTO recipe_ratings (recipe_type, recipe_id, user_id, stars)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE stars = VALUES(stars), updated_at = NOW()`,
      [recipeType, recipeId, userId, stars]
    );

    // Update recipe average rating
    await this.updateRecipeAverageRating(recipeId, recipeType);

    return {
      success: true,
      message: 'Rating added successfully'
    };
  }

  async updateRating(ratingId: string, userId: string, stars: number) {
    const [result] = await this.db.execute(
      'UPDATE recipe_ratings SET stars = ?, updated_at = NOW() WHERE id = ? AND user_id = ?',
      [stars, ratingId, userId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Rating not found or not authorized');
    }

    return {
      success: true,
      message: 'Rating updated successfully'
    };
  }

  async deleteRating(ratingId: string, userId: string) {
    // Get rating details first
    const [ratings] = await this.db.execute(
      'SELECT recipe_id, recipe_type FROM recipe_ratings WHERE id = ? AND user_id = ?',
      [ratingId, userId]
    );

    const rating = (ratings as any[])[0];
    if (!rating) {
      throw new NotFoundException('Rating not found or not authorized');
    }

    const [result] = await this.db.execute(
      'DELETE FROM recipe_ratings WHERE id = ? AND user_id = ?',
      [ratingId, userId]
    );

    // Update recipe average rating
    await this.updateRecipeAverageRating(rating.recipe_id, rating.recipe_type);

    return {
      success: true,
      message: 'Rating deleted successfully'
    };
  }

  async getUserRatings(userId: string, limit: number = 20, offset: number = 0) {
    const [ratings] = await this.db.execute(
      `SELECT 
        rr.id,
        rr.stars,
        rr.created_at,
        rr.updated_at,
        rr.recipe_id,
        rr.recipe_type,
        CASE 
          WHEN rr.recipe_type = 'SYSTEM' THEN r.name_vi
          WHEN rr.recipe_type = 'COMMUNITY' THEN cr.title
        END as recipe_name
      FROM recipe_ratings rr
      LEFT JOIN recipes r ON rr.recipe_id = r.id AND rr.recipe_type = 'SYSTEM'
      LEFT JOIN community_recipes cr ON rr.recipe_id = cr.id AND rr.recipe_type = 'COMMUNITY'
      WHERE rr.user_id = ?
      ORDER BY rr.created_at DESC
      LIMIT ? OFFSET ?`,
      [userId, limit, offset]
    );

    const [totalCount] = await this.db.execute(
      'SELECT COUNT(*) as total FROM recipe_ratings WHERE user_id = ?',
      [userId]
    );

    return {
      success: true,
      data: {
        ratings,
        pagination: {
          total: (totalCount as any[])[0].total,
          limit,
          offset,
          has_more: (totalCount as any[])[0].total > offset + limit
        }
      }
    };
  }

  async getTopRatedRecipes(recipeType: 'SYSTEM' | 'COMMUNITY', limit: number = 10) {
    const [recipes] = await this.db.execute(
      `SELECT 
        r.id,
        r.name_vi,
        r.name_en,
        r.image_url,
        r.difficulty,
        r.cook_time_min,
        AVG(rr.stars) as avg_rating,
        COUNT(rr.id) as rating_count
      FROM ${recipeType === 'SYSTEM' ? 'recipes' : 'community_recipes'} r
      LEFT JOIN recipe_ratings rr ON r.id = rr.recipe_id AND rr.recipe_type = ?
      WHERE r.is_public = 1 ${recipeType === 'COMMUNITY' ? "AND r.status = 'APPROVED'" : ''}
      GROUP BY r.id
      HAVING rating_count >= 5
      ORDER BY avg_rating DESC, rating_count DESC
      LIMIT ?`,
      [recipeType, limit]
    );

    return {
      success: true,
      data: recipes
    };
  }

  async getUserRatingForRecipe(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', userId: string) {
    const [ratings] = await this.db.execute(
      'SELECT * FROM recipe_ratings WHERE recipe_id = ? AND recipe_type = ? AND user_id = ?',
      [recipeId, recipeType, userId]
    );

    const rating = (ratings as any[])[0];
    return {
      success: true,
      data: rating || null
    };
  }

  private async getRatingDistribution(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY') {
    const [distribution] = await this.db.execute(
      `SELECT 
        stars,
        COUNT(*) as count
      FROM recipe_ratings 
      WHERE recipe_id = ? AND recipe_type = ?
      GROUP BY stars
      ORDER BY stars DESC`,
      [recipeId, recipeType]
    );

    // Initialize distribution with zeros
    const result = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
    
    for (const item of distribution as any[]) {
      result[item.stars] = item.count;
    }

    return result;
  }

  private async updateRecipeAverageRating(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY') {
    const [avgRating] = await this.db.execute(
      'SELECT AVG(stars) as average, COUNT(*) as count FROM recipe_ratings WHERE recipe_id = ? AND recipe_type = ?',
      [recipeId, recipeType]
    );

    const stats = (avgRating as any[])[0];
    const average = parseFloat(stats.average || 0).toFixed(1);
    const count = stats.count;

    if (recipeType === 'SYSTEM') {
      await this.db.execute(
        'UPDATE recipes SET rating_avg = ?, rating_count = ? WHERE id = ?',
        [average, count, recipeId]
      );
    } else {
      // For community recipes, we might want to store this in a separate table
      // or update the community_recipes table if it has rating fields
    }
  }

  async getRatingStatistics() {
    const [systemStats] = await this.db.execute(
      `SELECT 
        COUNT(*) as total_ratings,
        AVG(stars) as avg_rating,
        COUNT(DISTINCT recipe_id) as rated_recipes,
        COUNT(DISTINCT user_id) as rating_users
      FROM recipe_ratings 
      WHERE recipe_type = 'SYSTEM'`
    );

    const [communityStats] = await this.db.execute(
      `SELECT 
        COUNT(*) as total_ratings,
        AVG(stars) as avg_rating,
        COUNT(DISTINCT recipe_id) as rated_recipes,
        COUNT(DISTINCT user_id) as rating_users
      FROM recipe_ratings 
      WHERE recipe_type = 'COMMUNITY'`
    );

    return {
      success: true,
      data: {
        system_recipes: (systemStats as any[])[0],
        community_recipes: (communityStats as any[])[0]
      }
    };
  }
}
