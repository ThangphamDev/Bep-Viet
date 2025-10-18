import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { PricesService } from './prices.service';
import { CreatePriceDto, UpdatePriceDto } from './dto/prices.dto';

@ApiTags('Prices')
@Controller('prices')
export class PricesController {
  constructor(private readonly pricesService: PricesService) {}

  @Get('region/:region')
  @ApiOperation({ summary: 'Get prices by region' })
  @ApiParam({ name: 'region', description: 'Region code (BAC, TRUNG, NAM)' })
  @ApiResponse({ status: 200, description: 'Prices for the region' })
  async getPricesByRegion(@Param('region') region: string) {
    return this.pricesService.getPricesByRegion(region);
  }

  @Get('ingredient/:ingredientId/region/:region')
  @ApiOperation({ summary: 'Get ingredient prices by region' })
  @ApiParam({ name: 'ingredientId', description: 'Ingredient ID' })
  @ApiParam({ name: 'region', description: 'Region code' })
  @ApiQuery({ name: 'unit', required: false, description: 'Filter by unit' })
  @ApiResponse({ status: 200, description: 'Ingredient prices' })
  async getIngredientPrices(
    @Param('ingredientId') ingredientId: string,
    @Param('region') region: string,
    @Query('unit') unit?: string
  ) {
    return this.pricesService.getPriceByIngredientAndRegion(ingredientId, region, unit);
  }

  @Get('recipe/:recipeId/cost')
  @ApiOperation({ summary: 'Estimate recipe cost' })
  @ApiParam({ name: 'recipeId', description: 'Recipe ID' })
  @ApiQuery({ name: 'region', description: 'Region code' })
  @ApiQuery({ name: 'servings', required: false, description: 'Number of servings', example: 1 })
  @ApiResponse({ status: 200, description: 'Recipe cost estimation' })
  async estimateRecipeCost(
    @Param('recipeId') recipeId: string,
    @Query('region') region: string,
    @Query('servings') servings?: string
  ) {
    return this.pricesService.estimateRecipeCost(recipeId, region, parseInt(servings || '1'));
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create new price (Admin only)' })
  @ApiResponse({ status: 201, description: 'Price created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async createPrice(@Body() createPriceDto: CreatePriceDto) {
    return this.pricesService.createPrice(createPriceDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update price (Admin only)' })
  @ApiParam({ name: 'id', description: 'Price ID' })
  @ApiResponse({ status: 200, description: 'Price updated successfully' })
  @ApiResponse({ status: 404, description: 'Price not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async updatePrice(
    @Param('id') id: string,
    @Body() updatePriceDto: UpdatePriceDto
  ) {
    return this.pricesService.updatePrice(id, updatePriceDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete price (Admin only)' })
  @ApiParam({ name: 'id', description: 'Price ID' })
  @ApiResponse({ status: 200, description: 'Price deleted successfully' })
  @ApiResponse({ status: 404, description: 'Price not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async deletePrice(@Param('id') id: string) {
    return this.pricesService.deletePrice(id);
  }
}