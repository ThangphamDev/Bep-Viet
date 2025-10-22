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

    // Get plan details to calculate amount
    const [plans] = await this.db.execute(
      `SELECT price FROM subscription_plans WHERE id = ?`,
      [plan]
    );
    const planData = (plans as any[])[0];
    const amount = planData ? planData.price * duration_months : 0;

    // Generate UUID for subscription
    const [uuidResult] = await this.db.execute('SELECT UUID() as id');
    const subscriptionId = (uuidResult as any[])[0].id;

    // Cancel any existing active subscriptions for this user
    await this.db.execute(
      `UPDATE subscriptions 
       SET status = 'CANCELLED', ended_at = NOW() 
       WHERE user_id = ? AND status = 'ACTIVE'`,
      [userId]
    );

    // Create subscription (convert plan to uppercase for subscriptions table)
    const planUpper = plan.toUpperCase();
    await this.db.execute(
      `INSERT INTO subscriptions (id, user_id, plan, status, started_at, ended_at)
       VALUES (?, ?, ?, 'ACTIVE', ?, ?)`,
      [subscriptionId, userId, planUpper, startDate, endDate]
    );

    // Create transaction record
    await this.db.execute(
      `INSERT INTO subscription_transactions 
        (user_id, plan_id, amount, status, payment_method, started_at, ended_at)
       VALUES (?, ?, ?, 'COMPLETED', 'DIRECT', ?, ?)`,
      [userId, plan, amount, startDate, endDate]
    );

    return {
      success: true,
      data: { 
        id: subscriptionId,
        plan: planUpper,
        status: 'ACTIVE',
        started_at: startDate,
        ended_at: endDate,
      },
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

  async getSubscriptionPlans() {
    const [plans] = await this.db.execute(
      `SELECT 
        id,
        name,
        name_en,
        price,
        duration,
        features,
        is_popular,
        display_order,
        is_active
      FROM subscription_plans
      WHERE is_active = 1
      ORDER BY display_order ASC`
    );

    return {
      success: true,
      data: plans,
    };
  }

  async getUserTransactions(userId: string) {
    if (!userId) {
      throw new Error('User ID is required');
    }

    const [transactions] = await this.db.execute(
      `SELECT 
        st.id,
        st.plan_id,
        sp.name as plan_name,
        sp.name_en as plan_name_en,
        st.amount,
        st.status,
        st.payment_method,
        st.transaction_ref,
        st.started_at,
        st.ended_at,
        st.created_at
      FROM subscription_transactions st
      LEFT JOIN subscription_plans sp ON st.plan_id = sp.id
      WHERE st.user_id = ?
      ORDER BY st.created_at DESC`,
      [userId]
    );

    return {
      success: true,
      data: transactions,
    };
  }

  async createTransaction(userId: string, transactionData: any) {
    const { plan_id, amount, payment_method, transaction_ref, started_at, ended_at } = transactionData;

    const [result] = await this.db.execute(
      `INSERT INTO subscription_transactions 
        (user_id, plan_id, amount, status, payment_method, transaction_ref, started_at, ended_at)
       VALUES (?, ?, ?, 'PENDING', ?, ?, ?, ?)`,
      [userId, plan_id, amount, payment_method, transaction_ref, started_at, ended_at]
    );

    return {
      success: true,
      data: { id: (result as any).insertId },
    };
  }

  async updateTransactionStatus(transactionId: string, status: string) {
    await this.db.execute(
      `UPDATE subscription_transactions SET status = ? WHERE id = ?`,
      [status, transactionId]
    );

    return {
      success: true,
      message: 'Transaction status updated successfully',
    };
  }
}
