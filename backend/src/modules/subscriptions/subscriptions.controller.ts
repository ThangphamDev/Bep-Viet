import { Controller, Get, Post, Put, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { SubscriptionsService } from './subscriptions.service';

@ApiTags('Subscriptions')
@Controller('subscriptions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SubscriptionsController {
  constructor(private readonly subscriptionsService: SubscriptionsService) {}

  @Get('plans')
  @ApiOperation({ summary: 'Get all subscription plans' })
  @ApiResponse({ status: 200, description: 'List of subscription plans' })
  async getSubscriptionPlans() {
    return this.subscriptionsService.getSubscriptionPlans();
  }

  @Get()
  @ApiOperation({ summary: 'Get user subscription' })
  @ApiResponse({ status: 200, description: 'User subscription details' })
  async getUserSubscription(@Request() req) {
    return this.subscriptionsService.getUserSubscription(req.user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Create subscription' })
  @ApiResponse({ status: 201, description: 'Subscription created successfully' })
  async createSubscription(
    @Request() req,
    @Body() subscriptionData: any
  ) {
    return this.subscriptionsService.createSubscription(req.user.id, subscriptionData);
  }

  @Put(':id/cancel')
  @ApiOperation({ summary: 'Cancel subscription' })
  @ApiResponse({ status: 200, description: 'Subscription cancelled successfully' })
  async cancelSubscription(
    @Param('id') subscriptionId: string,
    @Request() req
  ) {
    return this.subscriptionsService.cancelSubscription(subscriptionId, req.user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Get user subscription transactions' })
  @ApiResponse({ status: 200, description: 'List of user transactions' })
  async getUserTransactions(@Request() req) {
    return this.subscriptionsService.getUserTransactions(req.user.id);
  }

  @Post('transactions')
  @ApiOperation({ summary: 'Create subscription transaction' })
  @ApiResponse({ status: 201, description: 'Transaction created successfully' })
  async createTransaction(
    @Request() req,
    @Body() transactionData: any
  ) {
    return this.subscriptionsService.createTransaction(req.user.id, transactionData);
  }

  @Put('transactions/:id/status')
  @ApiOperation({ summary: 'Update transaction status' })
  @ApiResponse({ status: 200, description: 'Transaction status updated successfully' })
  async updateTransactionStatus(
    @Param('id') transactionId: string,
    @Body('status') status: string
  ) {
    return this.subscriptionsService.updateTransactionStatus(transactionId, status);
  }
}
