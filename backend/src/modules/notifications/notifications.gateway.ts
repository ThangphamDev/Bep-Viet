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
import { Logger, UseGuards } from '@nestjs/common';
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

  constructor(private readonly jwtService: JwtService) {}

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

  // Mark notification as read
  @SubscribeMessage('mark_read')
  handleMarkRead(
    @MessageBody() data: { notificationId: string },
    @ConnectedSocket() client: AuthenticatedSocket,
  ) {
    this.logger.log(
      `User ${client.userId} marked notification ${data.notificationId} as read`,
    );
    return { success: true };
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

