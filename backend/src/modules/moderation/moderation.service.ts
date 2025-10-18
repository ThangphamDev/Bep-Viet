import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class ModerationService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getPendingModerations() {
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
      
      UNION ALL
      
      SELECT 
        'COMMENT' as type,
        rc.id,
        rc.content as title,
        cr.status,
        rc.created_at,
        u.name as author_name
      FROM comment_reports cr
      JOIN recipe_comments rc ON cr.comment_id = rc.id
      JOIN users u ON rc.user_id = u.id
      WHERE cr.status = 'PENDING'
      
      ORDER BY created_at ASC`
    );

    return {
      success: true,
      data: pending,
    };
  }

  async moderateContent(targetType: string, targetId: string, adminUserId: string, action: string, note?: string) {
    await this.db.execute(
      `INSERT INTO moderation_actions (target_type, target_id, admin_user_id, action, note)
       VALUES (?, ?, ?, ?, ?)`,
      [targetType, targetId, adminUserId, action, note]
    );

    return {
      success: true,
      message: `Content ${action}d successfully`,
    };
  }
}
