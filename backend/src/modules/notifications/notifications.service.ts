import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class NotificationsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async createNotification(
    userId: string,
    type: string,
    title: string,
    body: string,
    payload?: any
  ) {
    try {
      const [uuidResult] = await this.db.execute('SELECT UUID() as id');
      const notificationId = (uuidResult as any[])[0].id;

      await this.db.execute(
        `INSERT INTO notifications (id, user_id, type, title, body, payload_json, delivered_at)
         VALUES (?, ?, ?, ?, ?, ?, NOW())`,
        [
          notificationId,
          userId,
          type,
          title,
          body,
          payload ? JSON.stringify(payload) : null,
        ]
      );

      return {
        success: true,
        data: {
          id: notificationId,
          userId,
          type,
          title,
          body,
          payload,
        },
      };
    } catch (error) {
      console.error('Error creating notification:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async getUserNotifications(userId: string, limit: number = 20, offset: number = 0) {
    try {
      const [notifications] = await this.db.execute(
        `SELECT 
          id,
          type,
          title,
          body,
          payload_json,
          delivered_at,
          read_at,
          CASE WHEN read_at IS NULL THEN 0 ELSE 1 END as is_read
        FROM notifications 
        WHERE user_id = ? 
        ORDER BY delivered_at DESC 
        LIMIT ? OFFSET ?`,
        [userId, limit, offset]
      );

      return {
        success: true,
        data: notifications.map((notif: any) => ({
          ...notif,
          payload: notif.payload_json ? JSON.parse(notif.payload_json) : null,
        })),
      };
    } catch (error) {
      console.error('Error fetching notifications:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async markAsRead(notificationId: string, userId: string) {
    try {
      await this.db.execute(
        'UPDATE notifications SET read_at = NOW() WHERE id = ? AND user_id = ?',
        [notificationId, userId]
      );

      return { success: true };
    } catch (error) {
      console.error('Error marking notification as read:', error);
      return { success: false, error: error.message };
    }
  }

  async markAllAsRead(userId: string) {
    try {
      await this.db.execute(
        'UPDATE notifications SET read_at = NOW() WHERE user_id = ? AND read_at IS NULL',
        [userId]
      );

      return { success: true };
    } catch (error) {
      console.error('Error marking all notifications as read:', error);
      return { success: false, error: error.message };
    }
  }

  async getUnreadCount(userId: string) {
    try {
      const [result] = await this.db.execute(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND read_at IS NULL',
        [userId]
      );

      return {
        success: true,
        data: {
          unreadCount: (result as any[])[0].count,
        },
      };
    } catch (error) {
      console.error('Error getting unread count:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  // Specific notification types
  async notifyRecipePromoted(userId: string, recipeTitle: string, recipeId: string) {
    return this.createNotification(
      userId,
      'RECIPE_PROMOTED',
      '🎉 Công thức của bạn đã được nổi bật!',
      `Công thức "${recipeTitle}" đã được admin chọn làm công thức nổi bật và hiển thị trên trang chủ.`,
      {
        recipeId,
        recipeTitle,
        action: 'view_recipe',
      }
    );
  }

  async notifyRecipeApproved(userId: string, recipeTitle: string, recipeId: string) {
    return this.createNotification(
      userId,
      'RECIPE_APPROVED',
      '✅ Công thức đã được duyệt',
      `Công thức "${recipeTitle}" đã được admin duyệt và hiển thị trong cộng đồng.`,
      {
        recipeId,
        recipeTitle,
        action: 'view_recipe',
      }
    );
  }

  async notifyRecipeRejected(userId: string, recipeTitle: string, reason?: string) {
    return this.createNotification(
      userId,
      'RECIPE_REJECTED',
      '❌ Công thức cần chỉnh sửa',
      `Công thức "${recipeTitle}" cần được chỉnh sửa. ${reason ? `Lý do: ${reason}` : ''}`,
      {
        recipeTitle,
        reason,
        action: 'edit_recipe',
      }
    );
  }

  async notifyCommentReceived(userId: string, recipeTitle: string, commenterName: string, recipeId: string) {
    return this.createNotification(
      userId,
      'COMMENT_RECEIVED',
      '💬 Có bình luận mới',
      `${commenterName} đã bình luận về công thức "${recipeTitle}" của bạn.`,
      {
        recipeId,
        recipeTitle,
        commenterName,
        action: 'view_recipe',
      }
    );
  }

  async notifyRatingReceived(userId: string, recipeTitle: string, rating: number, recipeId: string) {
    return this.createNotification(
      userId,
      'RATING_RECEIVED',
      '⭐ Có đánh giá mới',
      `Có người đánh giá ${rating} sao cho công thức "${recipeTitle}" của bạn.`,
      {
        recipeId,
        recipeTitle,
        rating,
        action: 'view_recipe',
      }
    );
  }
}
