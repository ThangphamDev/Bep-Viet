import { Injectable, NotFoundException } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class CommentsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getComments(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', limit: number = 20, offset: number = 0) {
    const [comments] = await this.db.execute(
      `SELECT 
        rc.id,
        rc.content,
        rc.likes,
        rc.created_at,
        u.id as user_id,
        u.name as user_name,
        u.role as user_role
      FROM recipe_comments rc
      JOIN users u ON rc.user_id = u.id
      WHERE rc.recipe_id = ? AND rc.recipe_type = ?
      ORDER BY rc.created_at DESC
      LIMIT ${limit} OFFSET ${offset}`,
      [recipeId, recipeType]
    );

    const [totalCount] = await this.db.execute(
      'SELECT COUNT(*) as total FROM recipe_comments WHERE recipe_id = ? AND recipe_type = ?',
      [recipeId, recipeType]
    );

    return {
      success: true,
      data: {
        comments,
        pagination: {
          total: (totalCount as any[])[0].total,
          limit,
          offset,
          has_more: (totalCount as any[])[0].total > offset + limit
        }
      }
    };
  }

  async addComment(recipeId: string, recipeType: 'SYSTEM' | 'COMMUNITY', userId: string, content: string) {
    // Generate UUID
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const commentId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO recipe_comments (id, recipe_type, recipe_id, user_id, content)
       VALUES (?, ?, ?, ?, ?)`,
      [commentId, recipeType, recipeId, userId, content]
    );

    return {
      success: true,
      data: { id: commentId },
      message: 'Comment added successfully'
    };
  }

  async updateComment(commentId: string, userId: string, content: string) {
    const [result] = await this.db.execute(
      'UPDATE recipe_comments SET content = ? WHERE id = ? AND user_id = ?',
      [content, commentId, userId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Comment not found or not authorized');
    }

    return {
      success: true,
      message: 'Comment updated successfully'
    };
  }

  async deleteComment(commentId: string, userId: string) {
    const [result] = await this.db.execute(
      'DELETE FROM recipe_comments WHERE id = ? AND user_id = ?',
      [commentId, userId]
    );

    if ((result as any).affectedRows === 0) {
      throw new NotFoundException('Comment not found or not authorized');
    }

    return {
      success: true,
      message: 'Comment deleted successfully'
    };
  }

  async likeComment(commentId: string, userId: string) {
    // Simple increment - no tracking of individual likes (table doesn't exist)
    // This is a simplified version without like tracking per user
    await this.db.execute(
      'UPDATE recipe_comments SET likes = likes + 1 WHERE id = ?',
      [commentId]
    );

    return {
      success: true,
      message: 'Comment liked',
      liked: true
    };
  }

  async getUserComments(userId: string, limit: number = 20, offset: number = 0) {
    const [comments] = await this.db.execute(
      `SELECT 
        rc.id,
        rc.content,
        rc.likes,
        rc.created_at,
        rc.recipe_id,
        rc.recipe_type,
        CASE 
          WHEN rc.recipe_type = 'SYSTEM' THEN r.name_vi
          WHEN rc.recipe_type = 'COMMUNITY' THEN cr.title
        END as recipe_name
      FROM recipe_comments rc
      LEFT JOIN recipes r ON rc.recipe_id = r.id AND rc.recipe_type = 'SYSTEM'
      LEFT JOIN community_recipes cr ON rc.recipe_id = cr.id AND rc.recipe_type = 'COMMUNITY'
      WHERE rc.user_id = ?
      ORDER BY rc.created_at DESC
      LIMIT ${limit} OFFSET ${offset}`,
      [userId]
    );

    const [totalCount] = await this.db.execute(
      'SELECT COUNT(*) as total FROM recipe_comments WHERE user_id = ?',
      [userId]
    );

    return {
      success: true,
      data: {
        comments,
        pagination: {
          total: (totalCount as any[])[0].total,
          limit,
          offset,
          has_more: (totalCount as any[])[0].total > offset + limit
        }
      }
    };
  }

}
