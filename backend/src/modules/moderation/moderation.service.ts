import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class ModerationService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getPendingModerations() {
    // Only get pending community recipes (comment_reports table doesn't exist)
    const [pending] = await this.db.execute(
      `SELECT 
        'COMMUNITY_RECIPE' as type,
        cr.id,
        cr.title,
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
      data: pending,
    };
  }

  async moderateContent(targetType: string, targetId: string, adminUserId: string, action: string, note?: string) {
    // Generate UUID for moderation action
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const actionId = (uuidResult as any[])[0].id;

    await this.db.execute(
      `INSERT INTO moderation_actions (id, target_type, target_id, admin_user_id, action, note)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [actionId, targetType, targetId, adminUserId, action, note ?? null]
    );

    // Update community recipe status if applicable
    if (targetType === 'COMMUNITY_RECIPE') {
      let newStatus = 'PENDING';
      if (action === 'APPROVE') {
        newStatus = 'APPROVED';
      } else if (action === 'REJECT') {
        newStatus = 'REJECTED';
      } else if (action === 'DELETE') {
        // Delete the recipe
        await this.db.execute(
          'DELETE FROM community_recipes WHERE id = ?',
          [targetId]
        );
        return {
          success: true,
          message: 'Content deleted successfully',
        };
      }

      await this.db.execute(
        'UPDATE community_recipes SET status = ? WHERE id = ?',
        [newStatus, targetId]
      );
    }

    return {
      success: true,
      message: `Content ${action.toLowerCase()}d successfully`,
    };
  }
}
