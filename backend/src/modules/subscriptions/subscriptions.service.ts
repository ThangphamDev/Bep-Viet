import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class SubscriptionsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getUserSubscription(userId: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    const [subscriptions] = await this.db.execute(
      `SELECT 
        s.id,
        s.plan,
        s.status,
        s.started_at,
        s.ended_at
      FROM subscriptions s
      WHERE s.user_id = ? AND s.status = 'ACTIVE'
      ORDER BY s.started_at DESC
      LIMIT 1`,
      [userId]
    );

    return {
      success: true,
      data: (subscriptions as any[])[0] || null,
    };
  }

  async createSubscription(userId: string, subscriptionData: any) {
    const { plan, duration_months } = subscriptionData;

    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + duration_months);

    const [result] = await this.db.execute(
      `INSERT INTO subscriptions (user_id, plan, status, started_at, ended_at)
       VALUES (?, ?, 'ACTIVE', ?, ?)`,
      [userId, plan, startDate, endDate]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async cancelSubscription(subscriptionId: string, userId: string) {
    await this.db.execute(
      'UPDATE subscriptions SET status = "CANCELLED", ended_at = NOW() WHERE id = ? AND user_id = ?',
      [subscriptionId, userId]
    );

    return {
      success: true,
      message: 'Subscription cancelled successfully',
    };
  }
}
