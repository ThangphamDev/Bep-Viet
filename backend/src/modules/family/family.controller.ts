import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { FamilyService } from './family.service';
import { CheckAllergensDto } from './dto/check-allergens.dto';

@ApiTags('Family')
@Controller('family')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FamilyController {
  constructor(private readonly familyService: FamilyService) {}

  @Get('profiles')
  @ApiOperation({ summary: 'Get user family profiles' })
  @ApiResponse({ status: 200, description: 'List of family profiles' })
  async getUserFamilyProfiles(@Request() req) {
    return this.familyService.getUserFamilyProfiles(req.user.id);
  }

  @Post('profiles')
  @ApiOperation({ summary: 'Create family profile' })
  @ApiResponse({ status: 201, description: 'Family profile created successfully' })
  async createFamilyProfile(
    @Request() req,
    @Body() familyData: any
  ) {
    return this.familyService.createFamilyProfile(req.user.id, familyData);
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

  @Put('members/:id')
  @ApiOperation({ summary: 'Update family member' })
  @ApiResponse({ status: 200, description: 'Family member updated successfully' })
  async updateFamilyMember(
    @Param('id') memberId: string,
    @Body() memberData: any
  ) {
    return this.familyService.updateFamilyMember(memberId, memberData);
  }

  @Delete('members/:id')
  @ApiOperation({ summary: 'Delete family member' })
  @ApiResponse({ status: 200, description: 'Family member deleted successfully' })
  async deleteFamilyMember(
    @Param('id') memberId: string
  ) {
    return this.familyService.deleteFamilyMember(memberId);
  }

  @Post('check-allergens')
  @ApiOperation({ 
    summary: 'Check recipe allergens against family members (Premium Family feature)',
    description: 'Returns conflicts if recipe ingredients match family members allergens'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Allergen check completed',
    schema: {
      example: {
        success: true,
        hasConflicts: true,
        conflicts: [
          {
            memberId: 'uuid',
            memberName: 'Bé Minh',
            memberAgeGroup: 'KID',
            conflictingIngredients: [
              {
                ingredientId: 'uuid',
                ingredientName: 'Tôm'
              }
            ]
          }
        ]
      }
    }
  })
  async checkRecipeAllergens(
    @Request() req,
    @Body() dto: CheckAllergensDto
  ) {
    return this.familyService.checkRecipeAllergens(req.user.id, dto.recipeId);
  }
}
