import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { ModerationService } from './moderation.service';

@ApiTags('Moderation')
@Controller('moderation')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles('ADMIN')
@ApiBearerAuth()
export class ModerationController {
  constructor(private readonly moderationService: ModerationService) {}

  @Get('pending')
  @ApiOperation({ summary: 'Get pending moderations' })
  @ApiResponse({ status: 200, description: 'List of pending moderations' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getPendingModerations() {
    return this.moderationService.getPendingModerations();
  }

  @Post(':targetType/:targetId')
  @ApiOperation({ summary: 'Moderate content' })
  @ApiResponse({ status: 200, description: 'Content moderated successfully' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async moderateContent(
    @Param('targetType') targetType: string,
    @Param('targetId') targetId: string,
    @Query('adminUserId') adminUserId: string,
    @Body('action') action: string,
    @Body('note') note?: string
  ) {
    return this.moderationService.moderateContent(targetType, targetId, adminUserId, action, note);
  }
}
