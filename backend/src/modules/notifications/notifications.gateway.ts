import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
  SubscribeMessage,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards, Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

@WebSocketGateway({
  cors: {
    origin: '*', // In production, specify your mobile app domain
    credentials: true,
  },
  namespace: '/notifications',
})
export class NotificationsGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(NotificationsGateway.name);
  private readonly connectedUsers = new Map<string, string>(); // userId -> socketId

  constructor(
    private readonly jwtService: JwtService,
    @Inject('DATABASE_CONNECTION') private readonly db: any,
  ) {}

  async handleConnection(client: AuthenticatedSocket) {
    try {
      // Extract token from handshake
      const token =
        client.handshake.auth.token || client.handshake.headers.authorization;

      if (!token) {
        this.logger.warn(`Client ${client.id} connected without token`);
        client.disconnect();
        return;
      }

      // Verify JWT token
      const payload = await this.jwtService.verifyAsync(
        token.replace('Bearer ', ''),
      );
      const userId = payload.userId;

      // Store user connection
      client.userId = userId;
      this.connectedUsers.set(userId, client.id);

      this.logger.log(
        `User ${userId} connected via socket ${client.id}. Total users: ${this.connectedUsers.size}`,
      );

      // Join user to their personal room
      client.join(`user:${userId}`);

      // Send connection confirmation
      client.emit('connected', {
        message: 'Connected to notification service',
        userId,
      });
    } catch (error) {
      this.logger.error(`Connection error for ${client.id}:`, error.message);
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    if (client.userId) {
      this.connectedUsers.delete(client.userId);
      this.logger.log(
        `User ${client.userId} disconnected. Total users: ${this.connectedUsers.size}`,
      );
    } else {
      this.logger.log(`Anonymous client ${client.id} disconnected`);
    }
  }

  // Subscribe to notifications for authenticated user
  @SubscribeMessage('subscribe')
  handleSubscribe(@ConnectedSocket() client: AuthenticatedSocket) {
    if (client.userId) {
      this.logger.log(`User ${client.userId} subscribed to notifications`);
      return { success: true, message: 'Subscribed to notifications' };
    }
    return { success: false, message: 'Not authenticated' };
  }

  // Get notification history
  @SubscribeMessage('get_history')
  async handleGetHistory(@ConnectedSocket() client: AuthenticatedSocket) {
    try {
      if (!client.userId) {
        return { success: false, message: 'Not authenticated' };
      }

      // Fetch last 50 notifications for user
      const [notifications] = await this.db.execute(
        `SELECT id, user_id as userId, type, title, body, payload_json as payload, 
                delivered_at as deliveredAt, read_at as readAt,
                CASE WHEN read_at IS NOT NULL THEN 1 ELSE 0 END as isRead
         FROM notifications 
         WHERE user_id = ? 
         ORDER BY delivered_at DESC 
         LIMIT 50`,
        [client.userId],
      );

      // Parse payload_json to object (if string)
      const parsedNotifications = (notifications as any[]).map(notif => ({
        ...notif,
        payload: notif.payload 
          ? (typeof notif.payload === 'string' ? JSON.parse(notif.payload) : notif.payload)
          : null,
      }));

      this.logger.log(
        `Sent ${parsedNotifications.length} notification history to user ${client.userId}`,
      );

      return {
        success: true,
        notifications: parsedNotifications,
      };
    } catch (error) {
      this.logger.error(
        `Error fetching notification history for user ${client.userId}:`,
        error.message,
      );
      return { success: false, message: 'Failed to fetch notifications' };
    }
  }

  // Mark notification as read
  @SubscribeMessage('mark_read')
  async handleMarkRead(
    @MessageBody() data: { notificationId: string },
    @ConnectedSocket() client: AuthenticatedSocket,
  ) {
    try {
      if (!client.userId) {
        return { success: false, message: 'Not authenticated' };
      }

      // Update notification as read
      await this.db.execute(
        `UPDATE notifications 
         SET read_at = CURRENT_TIMESTAMP 
         WHERE id = ? AND user_id = ?`,
        [data.notificationId, client.userId],
      );

      this.logger.log(
        `User ${client.userId} marked notification ${data.notificationId} as read`,
      );
      return { success: true };
    } catch (error) {
      this.logger.error(`Error marking notification as read:`, error.message);
      return { success: false };
    }
  }

  /**
   * Send notification to specific user
   */
  sendNotificationToUser(userId: string, notification: any) {
    try {
      const socketId = this.connectedUsers.get(userId);

      if (socketId) {
        // User is online - send real-time
        this.server.to(`user:${userId}`).emit('notification', notification);
        this.logger.log(
          `Sent real-time notification to user ${userId}: ${notification.type}`,
        );
        return true;
      } else {
        // User is offline - notification is already saved in DB
        this.logger.log(
          `User ${userId} is offline, notification saved to DB only`,
        );
        return false;
      }
    } catch (error) {
      this.logger.error(
        `Error sending notification to user ${userId}:`,
        error.message,
      );
      return false;
    }
  }

  /**
   * Broadcast notification to all connected users
   */
  broadcastNotification(notification: any) {
    this.server.emit('broadcast', notification);
    this.logger.log(`Broadcasted notification: ${notification.type}`);
  }

  /**
   * Get online users count
   */
  getOnlineUsersCount(): number {
    return this.connectedUsers.size;
  }

  /**
   * Check if user is online
   */
  isUserOnline(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }
}

