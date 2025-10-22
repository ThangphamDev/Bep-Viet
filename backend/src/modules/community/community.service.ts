import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class CommunityService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  // Helper method to get ingredients and steps for a recipe
  private async getRecipeDetails(recipeId: string) {
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
      [recipeId]
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
      [recipeId]
    );

    return { ingredients, steps };
  }

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
        cr.image_url,
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

    query += ' GROUP BY cr.id, cr.title, cr.region, cr.description_md, cr.difficulty, cr.time_min, cr.cost_hint, cr.image_url, cr.status, cr.created_at, cr.updated_at, u.name ORDER BY cr.created_at DESC';

    if (filters.limit) {
      query += ' LIMIT ?';
      params.push(filters.limit);
    }

    const [recipes] = await this.db.execute(query, params);

    // Get ingredients and steps for each recipe
    const recipesWithDetails = await Promise.all(
      (recipes as any[]).map(async (recipe) => {
        const details = await this.getRecipeDetails(recipe.id);
        return {
          ...recipe,
          ...details,
        };
      })
    );

    return {
      success: true,
      data: recipesWithDetails,
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
        cr.image_url,
        cr.status,
        cr.created_at,
        cr.updated_at,
        u.name as author_name,
        u.id as author_id
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      WHERE cr.id = ?`,
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
      image_url,
      ingredients,
      steps
    } = recipeData;

    // Generate UUID for recipe
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const recipeId = (uuidResult as any[])[0].id;

    // Create community recipe
    await this.db.execute(
      `INSERT INTO community_recipes 
       (id, author_user_id, title, region, description_md, difficulty, time_min, cost_hint, image_url, status)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'APPROVED')`,
      [recipeId, userId, title, region ?? null, description_md, difficulty, time_min, cost_hint, image_url ?? null]
    );

    // Add ingredients
    for (const ingredient of ingredients) {
      const [ingredientUuidResult] = await this.db.execute('SELECT UUID() as id');
      const ingredientId = (ingredientUuidResult as any[])[0].id;
      
      await this.db.execute(
        `INSERT INTO community_recipe_ingredients 
         (id, community_recipe_id, ingredient_name, quantity, note)
         VALUES (?, ?, ?, ?, ?)`,
        [ingredientId, recipeId, ingredient.name, ingredient.quantity ?? null, ingredient.note ?? null]
      );
    }

    // Add steps
    for (const step of steps) {
      const [stepUuidResult] = await this.db.execute('SELECT UUID() as id');
      const stepId = (stepUuidResult as any[])[0].id;
      
      await this.db.execute(
        `INSERT INTO community_recipe_steps 
         (id, community_recipe_id, order_no, content_md)
         VALUES (?, ?, ?, ?)`,
        [stepId, recipeId, step.order_no, step.content_md]
      );
    }

    return {
      success: true,
      data: { id: recipeId },
      message: 'Community recipe created successfully'
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
        cr.image_url,
        cr.status,
        cr.created_at,
        u.name as author_name
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      WHERE cr.status = 'PENDING'
      ORDER BY cr.created_at ASC`
    );

    // Get ingredients and steps for each recipe
    const recipesWithDetails = await Promise.all(
      (recipes as any[]).map(async (recipe) => {
        const details = await this.getRecipeDetails(recipe.id);
        return {
          ...recipe,
          ...details,
        };
      })
    );

    return {
      success: true,
      data: recipesWithDetails,
    };
  }

  async moderateRecipe(recipeId: string, adminUserId: string, action: string, note?: string) {
    let newStatus = '';
    const actionLower = action.toLowerCase();
    switch (actionLower) {
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

    // Generate UUID for moderation action
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const actionId = (uuidResult as any[])[0].id;

    // Log moderation action
    await this.db.execute(
      `INSERT INTO moderation_actions (id, target_type, target_id, admin_user_id, action, note)
       VALUES (?, 'COMMUNITY_RECIPE', ?, ?, ?, ?)`,
      [actionId, recipeId, adminUserId, action.toUpperCase(), note ?? null]
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
        cr.image_url,
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
      GROUP BY cr.id, cr.title, cr.region, cr.image_url, cr.status, cr.created_at, cr.updated_at
      ORDER BY cr.created_at DESC`,
      [userId]
    );

    // Get ingredients and steps for each recipe
    const recipesWithDetails = await Promise.all(
      (recipes as any[]).map(async (recipe) => {
        const details = await this.getRecipeDetails(recipe.id);
        return {
          ...recipe,
          ...details,
        };
      })
    );

    return {
      success: true,
      data: recipesWithDetails,
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
        cr.image_url,
        cr.created_at,
        u.name as author_name,
        (SELECT COUNT(*) FROM recipe_comments WHERE recipe_id = cr.id AND recipe_type = 'COMMUNITY') as comment_count,
        (SELECT COUNT(*) FROM recipe_ratings WHERE recipe_id = cr.id AND recipe_type = 'COMMUNITY') as rating_count,
        (SELECT AVG(stars) FROM recipe_ratings WHERE recipe_id = cr.id AND recipe_type = 'COMMUNITY') as avg_rating
      FROM community_recipes cr
      JOIN users u ON cr.author_user_id = u.id
      WHERE cr.status = 'FEATURED'
      ORDER BY cr.created_at DESC
      LIMIT ${limit}`
    );

    // Get ingredients and steps for each recipe
    const recipesWithDetails = await Promise.all(
      (recipes as any[]).map(async (recipe) => {
        const details = await this.getRecipeDetails(recipe.id);
        return {
          ...recipe,
          ...details,
        };
      })
    );

    return {
      success: true,
      data: recipesWithDetails,
    };
  }

  async updateCommunityRecipe(recipeId: string, userId: string, updateData: any) {
    // Check if recipe exists and belongs to user
    const [recipes] = await this.db.execute(
      'SELECT id, author_user_id FROM community_recipes WHERE id = ?',
      [recipeId]
    );

    const recipe = (recipes as any[])[0];
    if (!recipe) {
      throw new NotFoundException('Community recipe not found');
    }

    if (recipe.author_user_id !== userId) {
      throw new Error('You are not authorized to update this recipe');
    }

    // Build UPDATE query dynamically for only provided fields
    const updateFields: string[] = [];
    const updateValues: any[] = [];

    if (updateData.title !== undefined) {
      updateFields.push('title = ?');
      updateValues.push(updateData.title);
    }
    if (updateData.region !== undefined) {
      updateFields.push('region = ?');
      updateValues.push(updateData.region);
    }
    if (updateData.description_md !== undefined) {
      updateFields.push('description_md = ?');
      updateValues.push(updateData.description_md);
    }
    if (updateData.difficulty !== undefined) {
      updateFields.push('difficulty = ?');
      updateValues.push(updateData.difficulty);
    }
    if (updateData.time_min !== undefined) {
      updateFields.push('time_min = ?');
      updateValues.push(updateData.time_min);
    }
    if (updateData.cost_hint !== undefined) {
      updateFields.push('cost_hint = ?');
      updateValues.push(updateData.cost_hint);
    }
    if (updateData.image_url !== undefined) {
      updateFields.push('image_url = ?');
      updateValues.push(updateData.image_url);
    }

    // Update recipe if there are fields to update
    if (updateFields.length > 0) {
      updateFields.push('updated_at = CURRENT_TIMESTAMP');
      updateValues.push(recipeId);
      
      await this.db.execute(
        `UPDATE community_recipes SET ${updateFields.join(', ')} WHERE id = ?`,
        updateValues
      );
    }

    // Update ingredients if provided
    if (updateData.ingredients !== undefined && Array.isArray(updateData.ingredients)) {
      // Delete existing ingredients
      await this.db.execute(
        'DELETE FROM community_recipe_ingredients WHERE community_recipe_id = ?',
        [recipeId]
      );

      // Add new ingredients
      for (const ingredient of updateData.ingredients) {
        const [ingredientUuidResult] = await this.db.execute('SELECT UUID() as id');
        const ingredientId = (ingredientUuidResult as any[])[0].id;
        
        await this.db.execute(
          `INSERT INTO community_recipe_ingredients 
           (id, community_recipe_id, ingredient_name, quantity, note)
           VALUES (?, ?, ?, ?, ?)`,
          [ingredientId, recipeId, ingredient.name, ingredient.quantity ?? null, ingredient.note ?? null]
        );
      }
    }

    // Update steps if provided
    if (updateData.steps !== undefined && Array.isArray(updateData.steps)) {
      // Delete existing steps
      await this.db.execute(
        'DELETE FROM community_recipe_steps WHERE community_recipe_id = ?',
        [recipeId]
      );

      // Add new steps
      for (const step of updateData.steps) {
        const [stepUuidResult] = await this.db.execute('SELECT UUID() as id');
        const stepId = (stepUuidResult as any[])[0].id;
        
        await this.db.execute(
          `INSERT INTO community_recipe_steps 
           (id, community_recipe_id, order_no, content_md)
           VALUES (?, ?, ?, ?)`,
          [stepId, recipeId, step.order_no, step.content_md]
        );
      }
    }

    // Return updated recipe
    return this.getCommunityRecipeById(recipeId);
  }

  async deleteCommunityRecipe(recipeId: string, userId: string) {
    // Check if recipe exists and belongs to user
    const [recipes] = await this.db.execute(
      'SELECT id, author_user_id FROM community_recipes WHERE id = ?',
      [recipeId]
    );

    const recipe = (recipes as any[])[0];
    if (!recipe) {
      throw new NotFoundException('Community recipe not found');
    }

    if (recipe.author_user_id !== userId) {
      throw new Error('You are not authorized to delete this recipe');
    }

    // Delete recipe (CASCADE will delete ingredients, steps, comments, ratings)
    await this.db.execute(
      'DELETE FROM community_recipes WHERE id = ?',
      [recipeId]
    );

    return {
      success: true,
      message: 'Community recipe deleted successfully'
    };
  }
}
