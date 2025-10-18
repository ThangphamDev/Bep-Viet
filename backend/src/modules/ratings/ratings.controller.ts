import { Controller, Get, Post, Put, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RatingsService } from './ratings.service';
import { AddRatingDto } from './dto/ratings.dto';

@ApiTags('Ratings')
@Controller('ratings')
export class RatingsController {
  constructor(private readonly ratingsService: RatingsService) {}

  @Get('recipes/:recipeId')
  @ApiOperation({ summary: 'Get recipe ratings' })
  @ApiParam({ name: 'recipeId', description: 'Recipe ID' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiResponse({ status: 200, description: 'Recipe ratings' })
  async getRecipeRatings(
    @Param('recipeId') recipeId: string,
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    return this.ratingsService.getRecipeRatings(
      recipeId, 
      recipeType, 
      parseInt(limit || '20'), 
      parseInt(offset || '0')
    );
  }

  @Post('recipes/:recipeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Rate recipe' })
  @ApiParam({ name: 'recipeId', description: 'Recipe ID' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiResponse({ status: 201, description: 'Rating added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addRating(
    @Param('recipeId') recipeId: string,
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Query('userId') userId: string,
    @Body() addRatingDto: AddRatingDto
  ) {
    return this.ratingsService.addRating(recipeId, recipeType, userId, addRatingDto.stars);
  }

  @Get('top-rated')
  @ApiOperation({ summary: 'Get top rated recipes' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiResponse({ status: 200, description: 'Top rated recipes' })
  async getTopRatedRecipes(
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Query('limit') limit?: string
  ) {
    return this.ratingsService.getTopRatedRecipes(recipeType, parseInt(limit || '10'));
  }

  @Get('my-ratings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user ratings' })
  @ApiResponse({ status: 200, description: 'User ratings' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserRatings(
    @Query('userId') userId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    return this.ratingsService.getUserRatings(
      userId, 
      parseInt(limit || '20'), 
      parseInt(offset || '0')
    );
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get rating statistics' })
  @ApiResponse({ status: 200, description: 'Rating statistics' })
  async getRatingStatistics() {
    return this.ratingsService.getRatingStatistics();
  }
}
