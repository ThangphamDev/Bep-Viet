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
}
