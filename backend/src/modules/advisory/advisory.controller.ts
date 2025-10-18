import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdvisoryService } from './advisory.service';

@ApiTags('Advisory')
@Controller('advisory')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AdvisoryController {
  constructor(private readonly advisoryService: AdvisoryService) {}

  @Get()
  @ApiOperation({ summary: 'Get user advisories' })
  @ApiResponse({ status: 200, description: 'List of advisories' })
  async getUserAdvisories(@Query('userId') userId: string) {
    return this.advisoryService.getUserAdvisories(userId);
  }

  @Post()
  @ApiOperation({ summary: 'Create advisory request' })
  @ApiResponse({ status: 201, description: 'Advisory created successfully' })
  async createAdvisory(
    @Query('userId') userId: string,
    @Body() advisoryData: any
  ) {
    return this.advisoryService.createAdvisory(userId, advisoryData);
  }
}
