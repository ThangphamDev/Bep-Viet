import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';
import { SeasonsService } from './seasons.service';

@ApiTags('Seasons')
@Controller('seasons')
export class SeasonsController {
  constructor(private readonly seasonsService: SeasonsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all seasons' })
  @ApiResponse({ status: 200, description: 'List of seasons' })
  async getAllSeasons() {
    return this.seasonsService.getAllSeasons();
  }

  @Get('current')
  @ApiOperation({ summary: 'Get current season' })
  @ApiResponse({ status: 200, description: 'Current season information' })
  async getCurrentSeason() {
    return this.seasonsService.getCurrentSeason();
  }

  @Get(':code')
  @ApiOperation({ summary: 'Get season by code' })
  @ApiParam({ name: 'code', description: 'Season code (XUAN, HA, THU, DONG)' })
  @ApiResponse({ status: 200, description: 'Season information' })
  async getSeasonByCode(@Param('code') code: string) {
    return this.seasonsService.getSeasonByCode(code);
  }

  @Get('ingredient/:ingredientId/seasonality')
  @ApiOperation({ summary: 'Get ingredient seasonality' })
  @ApiParam({ name: 'ingredientId', description: 'Ingredient ID' })
  @ApiQuery({ name: 'region', required: false, description: 'Filter by region' })
  @ApiResponse({ status: 200, description: 'Ingredient seasonality data' })
  async getIngredientSeasonality(
    @Param('ingredientId') ingredientId: string,
    @Query('region') region?: string
  ) {
    return this.seasonsService.getIngredientSeasonality(ingredientId, region);
  }
}