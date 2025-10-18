import { Controller, Get, Post, Put, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { CommunityService } from './community.service';
import { CreateCommunityRecipeDto, AddCommentDto, AddRatingDto } from './dto/community.dto';

@ApiTags('Community')
@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Get('recipes')
  @ApiOperation({ summary: 'Get all community recipes' })
  @ApiResponse({ status: 200, description: 'List of community recipes' })
  async getAllCommunityRecipes(@Query() filters: any) {
    return this.communityService.getAllCommunityRecipes(filters);
  }

  @Get('recipes/featured')
  @ApiOperation({ summary: 'Get featured community recipes' })
  @ApiResponse({ status: 200, description: 'List of featured recipes' })
  async getFeaturedRecipes(@Query('limit') limit?: string) {
    return this.communityService.getFeaturedRecipes(parseInt(limit || '10'));
  }

  @Get('recipes/:id')
  @ApiOperation({ summary: 'Get community recipe details' })
  @ApiParam({ name: 'id', description: 'Community recipe ID' })
  @ApiResponse({ status: 200, description: 'Community recipe details' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  async getCommunityRecipeById(@Param('id') id: string) {
    return this.communityService.getCommunityRecipeById(id);
  }

  @Post('recipes')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create community recipe' })
  @ApiResponse({ status: 201, description: 'Community recipe created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createCommunityRecipe(
    @Query('userId') userId: string,
    @Body() createCommunityRecipeDto: CreateCommunityRecipeDto
  ) {
    return this.communityService.createCommunityRecipe(userId, createCommunityRecipeDto);
  }

  @Post('recipes/:id/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add comment to recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Comment added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addComment(
    @Param('id') id: string,
    @Query('userId') userId: string,
    @Body() addCommentDto: AddCommentDto
  ) {
    return this.communityService.addComment(id, 'COMMUNITY', userId, addCommentDto.content);
  }

  @Post('recipes/:id/ratings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Rate recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Rating added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addRating(
    @Param('id') id: string,
    @Query('userId') userId: string,
    @Body() addRatingDto: AddRatingDto
  ) {
    return this.communityService.addRating(id, 'COMMUNITY', userId, addRatingDto.stars);
  }

  @Get('my-recipes')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user community recipes' })
  @ApiResponse({ status: 200, description: 'User community recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserCommunityRecipes(@Query('userId') userId: string) {
    return this.communityService.getUserCommunityRecipes(userId);
  }

  @Get('moderation/pending')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get pending recipes for moderation' })
  @ApiResponse({ status: 200, description: 'List of pending recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getPendingRecipes() {
    return this.communityService.getPendingRecipes();
  }

  @Put('moderation/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Moderate community recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe moderated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async moderateRecipe(
    @Param('id') id: string,
    @Query('adminUserId') adminUserId: string,
    @Body('action') action: string,
    @Body('note') note?: string
  ) {
    return this.communityService.moderateRecipe(id, adminUserId, action, note);
  }
}
