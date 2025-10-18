import { Injectable } from '@nestjs/common';
import { Inject } from '@nestjs/common';

@Injectable()
export class SubscriptionsService {
  constructor(@Inject('DATABASE_CONNECTION') private db: any) {}

  async getUserSubscription(userId: string) {
    const [subscriptions] = await this.db.execute(
      `SELECT 
        s.id,
        s.plan_name,
        s.status,
        s.start_date,
        s.end_date,
        s.auto_renew,
        s.created_at
      FROM subscriptions s
      WHERE s.user_id = ? AND s.status = 'ACTIVE'
      ORDER BY s.created_at DESC
      LIMIT 1`,
      [userId]
    );

    return {
      success: true,
      data: (subscriptions as any[])[0] || null,
    };
  }

  async createSubscription(userId: string, subscriptionData: any) {
    const { plan_name, duration_months, auto_renew } = subscriptionData;

    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + duration_months);

    const [result] = await this.db.execute(
      `INSERT INTO subscriptions (user_id, plan_name, status, start_date, end_date, auto_renew)
       VALUES (?, ?, 'ACTIVE', ?, ?, ?)`,
      [userId, plan_name, startDate, endDate, auto_renew]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async cancelSubscription(subscriptionId: string, userId: string) {
    await this.db.execute(
      'UPDATE subscriptions SET status = "CANCELLED" WHERE id = ? AND user_id = ?',
      [subscriptionId, userId]
    );

    return {
      success: true,
      message: 'Subscription cancelled successfully',
    };
  }
}
