import { Controller, Get, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { AnalyticsService } from './analytics.service';

@ApiTags('Analytics')
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @Get('user')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user analytics' })
  @ApiResponse({ status: 200, description: 'User analytics' })
  async getUserAnalytics(@Request() req) {
    return this.analyticsService.getUserAnalytics(req.user.id);
  }

  @Get('weekly-report')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get weekly health report' })
  @ApiResponse({ status: 200, description: 'Weekly health report' })
  async getWeeklyReport(@Request() req, @Query('week') weekStart?: string) {
    return this.analyticsService.getWeeklyReport(req.user.id, weekStart);
  }

  @Get('system')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get system analytics' })
  @ApiResponse({ status: 200, description: 'System analytics' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getSystemAnalytics() {
    return this.analyticsService.getSystemAnalytics();
  }
}
