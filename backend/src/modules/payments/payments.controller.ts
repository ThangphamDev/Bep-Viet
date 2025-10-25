import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  UseGuards,
  Request,
  Inject,
  BadRequestException,
  Logger,
  Res,
  Param,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { VNPayService } from './vnpay.service';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';
import type { Response } from 'express';
import { ConfigService } from '@nestjs/config';
import * as qs from 'qs';

@ApiTags('Payments')
@Controller('payments')
export class PaymentsController {
  private readonly logger = new Logger(PaymentsController.name);
  private readonly appDeepLink: string;

  constructor(
    private readonly vnpayService: VNPayService,
    private readonly subscriptionsService: SubscriptionsService,
    private readonly config: ConfigService,
    @Inject('DATABASE_CONNECTION') private db: any,
  ) {
    // ví dụ: bepviet://vnpay/return
    this.appDeepLink = (this.config.get('APP_DEEP_LINK') ?? 'bepviet://vnpay/return').trim();
  }

  @Post('vnpay/create')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create VNPay payment URL for subscription' })
  @ApiResponse({ status: 200, description: 'Payment URL created successfully' })
  async createVNPayPayment(
    @Request() req,
    @Body()
    body: {
      plan_id: string;
      duration_months: number;
      bank_code?: string;
    },
  ) {
    try {
      const userId = req.user.id;
      const { plan_id, duration_months, bank_code } = body;

      // Validate plan
      const [plans] = await this.db.execute(
        `SELECT id, name, price FROM subscription_plans WHERE id = ? AND is_active = 1`,
        [plan_id],
      );
      if (!plans || (plans as any[]).length === 0) {
        throw new BadRequestException('Invalid subscription plan');
      }

      const plan = (plans as any[])[0];
      const amount = plan.price * duration_months;

      // Create transaction record
      const [uuidResult] = await this.db.execute('SELECT UUID() as id');
      const transactionId = (uuidResult as any[])[0].id;

      const startDate = new Date();
      const endDate = new Date();
      endDate.setMonth(endDate.getMonth() + duration_months);

      await this.db.execute(
        `INSERT INTO subscription_transactions 
          (id, user_id, plan_id, amount, status, payment_method, started_at, ended_at)
         VALUES (?, ?, ?, ?, 'PENDING', 'VNPAY', ?, ?)`,
        [transactionId, userId, plan_id, amount, startDate, endDate],
      );

      // Create payment URL
      const ipAddr =
        req.headers['x-forwarded-for']?.toString().split(',')[0]?.trim() ||
        req.ip ||
        '127.0.0.1';

      const orderInfo = `Payment for ${plan_id} plan ${duration_months} month`;

      const paymentUrl = this.vnpayService.createPaymentUrl(
        transactionId,
        amount,
        orderInfo,
        ipAddr,
        bank_code,
      );

      this.logger.log(
        `Created VNPay payment for user ${userId}, transaction ${transactionId}`,
      );

      return {
        success: true,
        data: {
          transaction_id: transactionId,
          payment_url: paymentUrl,
          amount,
          plan_name: plan.name,
        },
        message: 'Payment URL created successfully',
      };
    } catch (error: any) {
      this.logger.error(`Error creating VNPay payment: ${error.message}`);
      throw error;
    }
  }

  @Get('vnpay/callback')
  @ApiOperation({ summary: 'VNPay IPN callback (server-to-server, authoritative)' })
  @ApiResponse({ status: 200, description: 'Callback processed' })
  async vnpayCallback(@Query() query: any, @Res() res: Response) {
    try {
      this.logger.log('Received VNPay IPN callback');
      const verification = this.vnpayService.verifyReturnUrl(query);

      if (!verification.isValid) {
        this.logger.warn(`Invalid VNPay IPN signature for order ${verification.orderId}`);
        return res.status(200).json({ RspCode: '97', Message: 'Invalid signature' });
      }

      const { orderId, responseCode, transactionNo } = verification;

      if (responseCode === '00') {
        // Success
        await this.db.execute(
          `UPDATE subscription_transactions 
           SET status = 'COMPLETED', transaction_ref = ?
           WHERE id = ?`,
          [transactionNo, orderId],
        );

        // Create/activate subscription
        const [transactions] = await this.db.execute(
          `SELECT user_id, plan_id, started_at, ended_at 
           FROM subscription_transactions 
           WHERE id = ?`,
          [orderId],
        );

        if (transactions && (transactions as any[]).length > 0) {
          const t = (transactions as any[])[0];

          await this.db.execute(
            `UPDATE subscriptions 
             SET status = 'CANCELLED', ended_at = NOW() 
             WHERE user_id = ? AND status = 'ACTIVE'`,
            [t.user_id],
          );

          const [subUuidResult] = await this.db.execute('SELECT UUID() as id');
          const subscriptionId = (subUuidResult as any[])[0].id;
          const planUpper = String(t.plan_id).toUpperCase();

          await this.db.execute(
            `INSERT INTO subscriptions (id, user_id, plan, status, started_at, ended_at)
             VALUES (?, ?, ?, 'ACTIVE', ?, ?)`,
            [subscriptionId, t.user_id, planUpper, t.started_at, t.ended_at],
          );

          this.logger.log(`Subscription activated for user ${t.user_id}, order ${orderId}`);
        }

        return res.status(200).json({ RspCode: '00', Message: 'Success' });
      } else {
        // Failed
        await this.db.execute(
          `UPDATE subscription_transactions 
           SET status = 'FAILED'
           WHERE id = ?`,
          [orderId],
        );
        this.logger.warn(`Payment failed for order ${orderId}, code: ${responseCode}`);
        return res.status(200).json({ RspCode: '00', Message: 'Success' });
      }
    } catch (error: any) {
      this.logger.error(`Error processing VNPay IPN: ${error.message}`);
      return res.status(200).json({ RspCode: '99', Message: 'Unknown error' });
    }
  }

  @Get('vnpay/return')
  @ApiOperation({ summary: 'VNPay return → 302 redirect to app deep link' })
  @ApiResponse({ status: 302, description: 'Redirect to app' })
  async vnpayReturn(@Query() query: any, @Res() res: Response) {
    try {
      this.logger.log('Received VNPay return, redirecting to app deep link');
      
      // Build deep link with all query parameters (not encoded)
      const deepLink = `${this.appDeepLink}?${qs.stringify(query, { encode: false })}`;
      this.logger.log(`Redirecting to: ${deepLink}`);
      
      // 302 redirect to app
      return res.redirect(302, deepLink);
    } catch (error: any) {
      this.logger.error(`Error processing VNPay return: ${error.message}`);
      // Fallback: redirect to app without params
      return res.redirect(302, this.appDeepLink);
    }
  }

  @Get('vnpay/status/:transactionId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Check payment status' })
  @ApiResponse({ status: 200, description: 'Transaction status' })
  async checkPaymentStatus(
    @Request() req,
    @Param('transactionId') transactionId: string,   // <— dùng Param thay vì Query
  ) {
    try {
      const userId = req.user.id;

      const [transactions] = await this.db.execute(
        `SELECT 
          st.id,
          st.status,
          st.amount,
          st.payment_method,
          st.transaction_ref,
          st.created_at,
          sp.name as plan_name
         FROM subscription_transactions st
         LEFT JOIN subscription_plans sp ON st.plan_id = sp.id
         WHERE st.id = ? AND st.user_id = ?`,
        [transactionId, userId],
      );

      if (!transactions || (transactions as any[]).length === 0) {
        throw new BadRequestException('Transaction not found');
      }

      const transaction = (transactions as any[])[0];
      return { success: true, data: transaction };
    } catch (error: any) {
      this.logger.error(`Error checking payment status: ${error.message}`);
      throw error;
    }
  }
}
