import { Injectable, NotFoundException, BadRequestException, forwardRef, Inject as NestInject } from '@nestjs/common';
import { Inject } from '@nestjs/common';
import { NotificationsGateway } from './notifications.gateway';

@Injectable()
export class NotificationsService {
  constructor(
    @Inject('DATABASE_CONNECTION') private db: any,
    @NestInject(forwardRef(() => NotificationsGateway))
    private readonly notificationsGateway: NotificationsGateway,
  ) {}

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

      const notificationData = {
        id: notificationId,
        userId,
        type,
        title,
        body,
        payload,
        delivered_at: new Date(),
        is_read: false,
      };

      // Send real-time notification via WebSocket
      this.notificationsGateway.sendNotificationToUser(userId, notificationData);

      return {
        success: true,
        data: notificationData,
      };
    } catch (error) {
      console.error('Error creating notification:', error);
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async getUserNotifications(
    userId: string,
    limit: number = 20,
    offset: number = 0,
    type?: string,
    read?: string // 'true', 'false', or 'all'
  ) {
    try {
      let query = `
        SELECT 
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
      `;
      const params: any[] = [userId];

      // Filter by type
      if (type) {
        query += ' AND type = ?';
        params.push(type);
      }

      // Filter by read status
      if (read === 'true') {
        query += ' AND read_at IS NOT NULL';
      } else if (read === 'false') {
        query += ' AND read_at IS NULL';
      }
      // If read === 'all', don't add filter

      query += ' ORDER BY delivered_at DESC LIMIT ? OFFSET ?';
      params.push(limit, offset);

      const [notifications] = await this.db.execute(query, params);

      return {
        success: true,
        data: (notifications as any[]).map((notif: any) => ({
          ...notif,
          payload: notif.payload_json ? JSON.parse(notif.payload_json) : null,
        })),
      };
    } catch (error) {
      throw new BadRequestException(`Failed to fetch notifications: ${error.message}`);
    }
  }

  async markAsRead(notificationId: string, userId: string) {
    try {
      const [result] = await this.db.execute(
        'UPDATE notifications SET read_at = NOW() WHERE id = ? AND user_id = ? AND read_at IS NULL',
        [notificationId, userId]
      );

      if ((result as any).affectedRows === 0) {
        throw new NotFoundException('Notification not found or already read');
      }

      return {
        success: true,
        message: 'Notification marked as read',
      };
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(`Failed to mark notification as read: ${error.message}`);
    }
  }

  async markAllAsRead(userId: string) {
    try {
      const [result] = await this.db.execute(
        'UPDATE notifications SET read_at = NOW() WHERE user_id = ? AND read_at IS NULL',
        [userId]
      );

      return {
        success: true,
        message: 'All notifications marked as read',
        data: {
          updated: (result as any).affectedRows,
        },
      };
    } catch (error) {
      throw new BadRequestException(`Failed to mark all notifications as read: ${error.message}`);
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
      throw new BadRequestException(`Failed to get unread count: ${error.message}`);
    }
  }

  async deleteNotification(notificationId: string, userId: string) {
    try {
      const [result] = await this.db.execute(
        'DELETE FROM notifications WHERE id = ? AND user_id = ?',
        [notificationId, userId]
      );

      if ((result as any).affectedRows === 0) {
        throw new NotFoundException('Notification not found');
      }

      return {
        success: true,
        message: 'Notification deleted',
      };
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      throw new BadRequestException(`Failed to delete notification: ${error.message}`);
    }
  }

  async deleteAllNotifications(userId: string) {
    try {
      const [result] = await this.db.execute(
        'DELETE FROM notifications WHERE user_id = ?',
        [userId]
      );

      return {
        success: true,
        message: 'All notifications deleted',
        data: {
          deleted: (result as any).affectedRows,
        },
      };
    } catch (error) {
      throw new BadRequestException(`Failed to delete all notifications: ${error.message}`);
    }
  }

  // ============ SYSTEM NOTIFICATION TYPES ============

  // Account notifications
  async notifyAccountBlocked(userId: string, reason?: string) {
    return this.createNotification(
      userId,
      'ACCOUNT_BLOCKED',
      '🚫 Tài khoản đã bị khóa',
      `Tài khoản của bạn đã bị khóa bởi quản trị viên.${reason ? ` Lý do: ${reason}` : ' Vui lòng liên hệ để biết thêm chi tiết.'}`,
      {
        reason,
        action: 'contact_support',
      }
    );
  }

  async notifyAccountUnblocked(userId: string) {
    return this.createNotification(
      userId,
      'ACCOUNT_UNBLOCKED',
      '✅ Tài khoản đã được mở khóa',
      `Tài khoản của bạn đã được quản trị viên mở khóa. Bạn có thể tiếp tục sử dụng ứng dụng.`,
      {
        action: 'continue_using',
      }
    );
  }

  // Recipe moderation notifications
  async notifyRecipePromotedToOfficial(userId: string, recipeTitle: string, recipeId: string) {
    return this.createNotification(
      userId,
      'RECIPE_PROMOTED_TO_OFFICIAL',
      '🎉 Công thức được chấp nhận!',
      `Chúc mừng! Công thức "${recipeTitle}" của bạn đã được admin duyệt và thêm vào danh sách công thức chính thức của Bếp Việt.`,
      {
        recipeId,
        recipeTitle,
        action: 'view_official_recipe',
      }
    );
  }

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
