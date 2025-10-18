import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class CommunityService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getAllCommunityRecipes(filters: any = {}) {
    let query = `
      SELECT 
        cr.id,
        cr.title,
        cr.region,
        cr.description_md,
        cr.difficulty,
        cr.time_min,
        cr.cost_hint,
        cr.status,
        cr.created_at,
        cr.updated_at,
        u.name as author_name,
        COUNT(DISTINCT rc.id) as comment_count,
        COUNT(DISTINCT rr.id) as rating_count,
        AVG(rr.stars) as avg_rating
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      LEFT JOIN recipe_comments rc ON cr.id = rc.recipe_id AND rc.recipe_type = 'COMMUNITY'
      LEFT JOIN recipe_ratings rr ON cr.id = rr.recipe_id AND rr.recipe_type = 'COMMUNITY'
      WHERE cr.status = 'APPROVED'
    `;
    
    let params: any[] = [];

    if (filters.region) {
      query += ' AND cr.region = ?';
      params.push(filters.region);
    }

    if (filters.difficulty) {
      query += ' AND cr.difficulty = ?';
      params.push(filters.difficulty);
    }

    if (filters.max_time) {
      query += ' AND cr.time_min <= ?';
      params.push(filters.max_time);
    }

    if (filters.search) {
      query += ' AND (cr.title LIKE ? OR cr.description_md LIKE ?)';
      params.push(`%${filters.search}%`, `%${filters.search}%`);
    }

    query += ' GROUP BY cr.id ORDER BY cr.created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ?';
      params.push(filters.limit);
    }

    const [recipes] = await this.db.execute(query, params);

    return {
      success: true,
      data: recipes,
    };
  }

  async getCommunityRecipeById(id: string) {
    const [recipes] = await this.db.execute(
      `SELECT 
        cr.id,
        cr.title,
        cr.region,
        cr.description_md,
        cr.difficulty,
        cr.time_min,
        cr.cost_hint,
        cr.status,
        cr.created_at,
        cr.updated_at,
        u.name as author_name,
        u.id as author_id
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      WHERE cr.id = ? AND cr.status = 'APPROVED'`,
      [id]
    );

    const recipe = (recipes as any[])[0];
    if (!recipe) {
      throw new NotFoundException('Community recipe not found');
    }

    // Get ingredients
    const [ingredients] = await this.db.execute(
      `SELECT 
        cri.id,
        cri.ingredient_name,
        cri.quantity,
        cri.note
      FROM community_recipe_ingredients cri
      WHERE cri.community_recipe_id = ?
      ORDER BY cri.id`,
      [id]
    );

    // Get steps
    const [steps] = await this.db.execute(
      `SELECT 
        crs.id,
        crs.order_no,
        crs.content_md
      FROM community_recipe_steps crs
      WHERE crs.community_recipe_id = ?
      ORDER BY crs.order_no`,
      [id]
    );

    // Get comments
    const [comments] = await this.db.execute(
      `SELECT 
        rc.id,
        rc.content,
        rc.likes,
        rc.created_at,
        u.name as author_name
      FROM recipe_comments rc
      JOIN users u ON rc.user_id = u.id
      WHERE rc.recipe_id = ? AND rc.recipe_type = 'COMMUNITY'
      ORDER BY rc.created_at DESC`,
      [id]
    );

    // Get ratings
    const [ratings] = await this.db.execute(
      `SELECT 
        rr.stars,
        rr.created_at,
        u.name as author_name
      FROM recipe_ratings rr
      JOIN users u ON rr.user_id = u.id
      WHERE rr.recipe_id = ? AND rr.recipe_type = 'COMMUNITY'
      ORDER BY rr.created_at DESC`,
      [id]
    );

    const avgRating = ratings.length > 0 
      ? ratings.reduce((sum: number, r: any) => sum + r.stars, 0) / ratings.length 
      : 0;

    return {
      success: true,
      data: {
        ...recipe,
        ingredients,
        steps,
        comments,
        ratings: {
          average: avgRating,
          count: ratings.length,
          details: ratings
        }
      },
    };
  }

  async createCommunityRecipe(userId: string, recipeData: any) {
    const {
      title,
      region,
      description_md,
      difficulty,
      time_min,
      cost_hint,
      ingredients,
      steps
    } = recipeData;

    // Create community recipe
    const [result] = await this.db.execute(
      `INSERT INTO community_recipes 
       (author_user_id, title, region, description_md, difficulty, time_min, cost_hint, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, 'PENDING')`,
      [userId, title, region, description_md, difficulty, time_min, cost_hint]
    );

    const recipeId = (result as any).insertId;

    // Add ingredients
    for (const ingredient of ingredients) {
      await this.db.execute(
        `INSERT INTO community_recipe_ingredients 
         (community_recipe_id, ingredient_name, quantity, note)
         VALUES (?, ?, ?, ?)`,
        [recipeId, ingredient.name, ingredient.quantity, ingredient.note]
      );
    }

    // Add steps
    for (const step of steps) {
      await this.db.execute(
        `INSERT INTO community_recipe_steps 
         (community_recipe_id, order_no, content_md)
         VALUES (?, ?, ?)`,
        [recipeId, step.order_no, step.content_md]
      );
    }

    return {
      success: true,
      data: { id: recipeId },
      message: 'Community recipe created successfully and pending approval'
    };
  }

  async addComment(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', userId: string, content: string) {
    const [result] = await this.db.execute(
      `INSERT INTO recipe_comments (recipe_type, recipe_id, user_id, content)
       VALUES (?, ?, ?, ?)`,
      [recipeType, recipeId, userId, content]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
      message: 'Comment added successfully'
    };
  }

  async addRating(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', userId: string, stars: number) {
    const [result] = await this.db.execute(
      `INSERT INTO recipe_ratings (recipe_type, recipe_id, user_id, stars)
       VALUES (?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE stars = VALUES(stars)`,
      [recipeType, recipeId, userId, stars]
    );

    return {
      success: true,
      message: 'Rating added successfully'
    };
  }

  async getPendingRecipes() {
    const [recipes] = await this.db.execute(
      `SELECT 
        cr.id,
        cr.title,
        cr.region,
        cr.description_md,
        cr.difficulty,
        cr.time_min,
        cr.cost_hint,
        cr.status,
        cr.created_at,
        u.name as author_name
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      WHERE cr.status = 'PENDING'
      ORDER BY cr.created_at ASC`
    );

    return {
      success: true,
      data: recipes,
    };
  }

  async moderateRecipe(recipeId: string, adminUserId: string, action: string, note?: string) {
    let newStatus = '';
    switch (action) {
      case 'approve':
        newStatus = 'APPROVED';
        break;
      case 'reject':
        newStatus = 'REJECTED';
        break;
      case 'feature':
        newStatus = 'FEATURED';
        break;
      default:
        throw new Error('Invalid moderation action');
    }

    // Update recipe status
    await this.db.execute(
      'UPDATE community_recipes SET status = ? WHERE id = ?',
      [newStatus, recipeId]
    );

    // Log moderation action
    await this.db.execute(
      `INSERT INTO moderation_actions (target_type, target_id, admin_user_id, action, note)
       VALUES ('COMMUNITY_RECIPE', ?, ?, ?, ?)`,
      [recipeId, adminUserId, action.toUpperCase(), note]
    );

    return {
      success: true,
      message: `Recipe ${action}d successfully`
    };
  }

  async getUserCommunityRecipes(userId: string) {
    const [recipes] = await this.db.execute(
      `SELECT 
        cr.id,
        cr.title,
        cr.region,
        cr.status,
        cr.created_at,
        cr.updated_at,
        COUNT(DISTINCT rc.id) as comment_count,
        COUNT(DISTINCT rr.id) as rating_count,
        AVG(rr.stars) as avg_rating
      FROM community_recipes cr
      LEFT JOIN recipe_comments rc ON cr.id = rc.recipe_id AND rc.recipe_type = 'COMMUNITY'
      LEFT JOIN recipe_ratings rr ON cr.id = rr.recipe_id AND rr.recipe_type = 'COMMUNITY'
      WHERE cr.author_user_id = ?
      GROUP BY cr.id
      ORDER BY cr.created_at DESC`,
      [userId]
    );

    return {
      success: true,
      data: recipes,
    };
  }

  async getFeaturedRecipes(limit: number = 10) {
    const [recipes] = await this.db.execute(
      `SELECT 
        cr.id,
        cr.title,
        cr.region,
        cr.description_md,
        cr.difficulty,
        cr.time_min,
        cr.cost_hint,
        cr.created_at,
        u.name as author_name,
        COUNT(DISTINCT rc.id) as comment_count,
        COUNT(DISTINCT rr.id) as rating_count,
        AVG(rr.stars) as avg_rating
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      LEFT JOIN recipe_comments rc ON cr.id = rc.recipe_id AND rc.recipe_type = 'COMMUNITY'
      LEFT JOIN recipe_ratings rr ON cr.id = rr.recipe_id AND rr.recipe_type = 'COMMUNITY'
      WHERE cr.status = 'FEATURED'
      GROUP BY cr.id
      ORDER BY cr.created_at DESC
      LIMIT ?`,
      [limit]
    );

    return {
      success: true,
      data: recipes,
    };
  }
}
