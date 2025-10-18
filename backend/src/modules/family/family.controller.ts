import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { FamilyService } from './family.service';

@ApiTags('Family')
@Controller('family')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FamilyController {
  constructor(private readonly familyService: FamilyService) {}

  @Get('profiles')
  @ApiOperation({ summary: 'Get user family profiles' })
  @ApiResponse({ status: 200, description: 'List of family profiles' })
  async getUserFamilyProfiles(@Query('userId') userId: string) {
    return this.familyService.getUserFamilyProfiles(userId);
  }

  @Post('profiles')
  @ApiOperation({ summary: 'Create family profile' })
  @ApiResponse({ status: 201, description: 'Family profile created successfully' })
  async createFamilyProfile(
    @Query('userId') userId: string,
    @Body() familyData: any
  ) {
    return this.familyService.createFamilyProfile(userId, familyData);
  }

  @Post('profiles/:id/members')
  @ApiOperation({ summary: 'Add family member' })
  @ApiResponse({ status: 201, description: 'Family member added successfully' })
  async addFamilyMember(
    @Param('id') familyId: string,
    @Body() memberData: any
  ) {
    return this.familyService.addFamilyMember(familyId, memberData);
  }
}
