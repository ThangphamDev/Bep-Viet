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
        rc.updated_at,
        u.id as user_id,
        u.name as user_name,
        u.role as user_role
      FROM recipe_comments rc
      JOIN users u ON rc.user_id = u.id
      WHERE rc.recipe_id = ? AND rc.recipe_type = ?
      ORDER BY rc.created_at DESC
      LIMIT ? OFFSET ?`,
      [recipeId, recipeType, limit, offset]
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

  async updateComment(commentId: string, userId: string, content: string) {
    const [result] = await this.db.execute(
      'UPDATE recipe_comments SET content = ?, updated_at = NOW() WHERE id = ? AND user_id = ?',
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
    // Check if user already liked this comment
    const [existingLikes] = await this.db.execute(
      'SELECT id FROM comment_likes WHERE comment_id = ? AND user_id = ?',
      [commentId, userId]
    );

    if ((existingLikes as any[]).length > 0) {
      // Unlike
      await this.db.execute(
        'DELETE FROM comment_likes WHERE comment_id = ? AND user_id = ?',
        [commentId, userId]
      );

      await this.db.execute(
        'UPDATE recipe_comments SET likes = GREATEST(0, likes - 1) WHERE id = ?',
        [commentId]
      );

      return {
        success: true,
        message: 'Comment unliked',
        liked: false
      };
    } else {
      // Like
      await this.db.execute(
        'INSERT INTO comment_likes (comment_id, user_id) VALUES (?, ?)',
        [commentId, userId]
      );

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
  }

  async getUserComments(userId: string, limit: number = 20, offset: number = 0) {
    const [comments] = await this.db.execute(
      `SELECT 
        rc.id,
        rc.content,
        rc.likes,
        rc.created_at,
        rc.updated_at,
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
      LIMIT ? OFFSET ?`,
      [userId, limit, offset]
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

  async reportComment(commentId: string, userId: string, reason: string) {
    const [result] = await this.db.execute(
      `INSERT INTO comment_reports (comment_id, reporter_user_id, reason, status)
       VALUES (?, ?, ?, 'PENDING')
       ON DUPLICATE KEY UPDATE reason = VALUES(reason)`,
      [commentId, userId, reason]
    );

    return {
      success: true,
      message: 'Comment reported successfully'
    };
  }

  async getReportedComments() {
    const [reports] = await this.db.execute(
      `SELECT 
        cr.id as report_id,
        cr.reason,
        cr.status,
        cr.created_at,
        rc.id as comment_id,
        rc.content,
        rc.likes,
        rc.created_at as comment_created_at,
        u.name as commenter_name,
        reporter.name as reporter_name
      FROM comment_reports cr
      JOIN recipe_comments rc ON cr.comment_id = rc.id
      JOIN users u ON rc.user_id = u.id
      JOIN users reporter ON cr.reporter_user_id = reporter.id
      WHERE cr.status = 'PENDING'
      ORDER BY cr.created_at DESC`
    );

    return {
      success: true,
      data: reports
    };
  }

  async moderateComment(reportId: string, adminUserId: string, action: string, note?: string) {
    // Get report details
    const [reports] = await this.db.execute(
      'SELECT comment_id FROM comment_reports WHERE id = ?',
      [reportId]
    );

    const report = (reports as any[])[0];
    if (!report) {
      throw new NotFoundException('Report not found');
    }

    let newStatus = '';
    switch (action) {
      case 'approve':
        newStatus = 'APPROVED';
        break;
      case 'reject':
        newStatus = 'REJECTED';
        break;
      case 'delete':
        newStatus = 'DELETED';
        // Delete the comment
        await this.db.execute(
          'DELETE FROM recipe_comments WHERE id = ?',
          [report.comment_id]
        );
        break;
      default:
        throw new Error('Invalid moderation action');
    }

    // Update report status
    await this.db.execute(
      'UPDATE comment_reports SET status = ? WHERE id = ?',
      [newStatus, reportId]
    );

    // Log moderation action
    await this.db.execute(
      `INSERT INTO moderation_actions (target_type, target_id, admin_user_id, action, note)
       VALUES ('COMMENT', ?, ?, ?, ?)`,
      [report.comment_id, adminUserId, action.toUpperCase(), note]
    );

    return {
      success: true,
      message: `Comment ${action}d successfully`
    };
  }
}
