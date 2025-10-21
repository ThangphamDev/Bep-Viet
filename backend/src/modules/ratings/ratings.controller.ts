import { Controller, Get, Post, Put, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
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
    const parsedLimit = parseInt(limit || '20', 10) || 20;
    const parsedOffset = parseInt(offset || '0', 10) || 0;
    return this.ratingsService.getRecipeRatings(
      recipeId, 
      recipeType, 
      parsedLimit, 
      parsedOffset
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
    @Request() req,
    @Body() addRatingDto: AddRatingDto
  ) {
    return this.ratingsService.addRating(recipeId, recipeType, req.user.id, addRatingDto.stars);
  }

  @Get('top-rated')
  @ApiOperation({ summary: 'Get top rated recipes' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiResponse({ status: 200, description: 'Top rated recipes' })
  async getTopRatedRecipes(
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Query('limit') limit?: string
  ) {
    const parsedLimit = parseInt(limit || '10', 10) || 10;
    return this.ratingsService.getTopRatedRecipes(recipeType, parsedLimit);
  }

  @Get('my-ratings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user ratings' })
  @ApiResponse({ status: 200, description: 'User ratings' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserRatings(
    @Request() req,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    const parsedLimit = parseInt(limit || '20', 10) || 20;
    const parsedOffset = parseInt(offset || '0', 10) || 0;
    return this.ratingsService.getUserRatings(
      req.user.id, 
      parsedLimit, 
      parsedOffset
    );
  }

  @Get('statistics')
  @ApiOperation({ summary: 'Get rating statistics' })
  @ApiResponse({ status: 200, description: 'Rating statistics' })
  async getRatingStatistics() {
    return this.ratingsService.getRatingStatistics();
  }
}
