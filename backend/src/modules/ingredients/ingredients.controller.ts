import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { IngredientsService } from './ingredients.service';
import { CreateIngredientDto, UpdateIngredientDto } from './dto/ingredients.dto';

@ApiTags('Ingredients')
@Controller('ingredients')
export class IngredientsController {
  constructor(private readonly ingredientsService: IngredientsService) {}

  @Get()
  @ApiOperation({ summary: 'Get all ingredients' })
  @ApiQuery({ name: 'search', required: false, description: 'Search term' })
  @ApiQuery({ name: 'category', required: false, description: 'Category ID' })
  @ApiResponse({ status: 200, description: 'List of ingredients' })
  async getAllIngredients(
    @Query('search') search?: string,
    @Query('category') category?: string
  ) {
    return this.ingredientsService.getAllIngredients(search, category ? parseInt(category) : undefined);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search ingredients' })
  @ApiQuery({ name: 'q', description: 'Search query' })
  @ApiResponse({ status: 200, description: 'Search results' })
  async searchIngredients(@Query('q') query: string) {
    return this.ingredientsService.searchIngredients(query);
  }

  @Get('categories')
  @ApiOperation({ summary: 'Get ingredient categories' })
  @ApiResponse({ status: 200, description: 'List of categories' })
  async getIngredientCategories() {
    return this.ingredientsService.getIngredientCategories();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get ingredient by ID' })
  @ApiParam({ name: 'id', description: 'Ingredient ID' })
  @ApiResponse({ status: 200, description: 'Ingredient details' })
  @ApiResponse({ status: 404, description: 'Ingredient not found' })
  async getIngredientById(@Param('id') id: string) {
    return this.ingredientsService.getIngredientById(id);
  }

  @Get(':id/prices')
  @ApiOperation({ summary: 'Get ingredient prices' })
  @ApiParam({ name: 'id', description: 'Ingredient ID' })
  @ApiQuery({ name: 'region', required: false, description: 'Filter by region' })
  @ApiResponse({ status: 200, description: 'Ingredient prices' })
  async getIngredientPrices(
    @Param('id') id: string,
    @Query('region') region?: string
  ) {
    return this.ingredientsService.getIngredientPrices(id, region);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create new ingredient (Admin only)' })
  @ApiResponse({ status: 201, description: 'Ingredient created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async createIngredient(@Body() createIngredientDto: CreateIngredientDto) {
    return this.ingredientsService.createIngredient(createIngredientDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update ingredient (Admin only)' })
  @ApiParam({ name: 'id', description: 'Ingredient ID' })
  @ApiResponse({ status: 200, description: 'Ingredient updated successfully' })
  @ApiResponse({ status: 404, description: 'Ingredient not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async updateIngredient(
    @Param('id') id: string,
    @Body() updateIngredientDto: UpdateIngredientDto
  ) {
    return this.ingredientsService.updateIngredient(id, updateIngredientDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete ingredient (Admin only)' })
  @ApiParam({ name: 'id', description: 'Ingredient ID' })
  @ApiResponse({ status: 200, description: 'Ingredient deleted successfully' })
  @ApiResponse({ status: 404, description: 'Ingredient not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async deleteIngredient(@Param('id') id: string) {
    return this.ingredientsService.deleteIngredient(id);
  }
}