import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { RecipesService } from './recipes.service';
import { CreateRecipeDto, UpdateRecipeDto, AddIngredientDto, AddTagDto } from './dto/recipes.dto';

@ApiTags('Recipes')
@Controller('recipes')
export class RecipesController {
  constructor(private readonly recipesService: RecipesService) {}

  @Get()
  @ApiOperation({ summary: 'Get all recipes' })
  @ApiQuery({ name: 'region', required: false, description: 'Filter by region (BAC, TRUNG, NAM)' })
  @ApiQuery({ name: 'max_time', required: false, description: 'Maximum cooking time' })
  @ApiQuery({ name: 'search', required: false, description: 'Search term' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results' })
  @ApiResponse({ status: 200, description: 'List of recipes' })
  async getAllRecipes(@Query() filters: any) {
    return this.recipesService.getAllRecipes(filters);
  }

  // Favorites - MUST be before :id routes to avoid conflict
  @Get('favorites')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user favorites' })
  @ApiResponse({ status: 200, description: 'List of favorite recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getFavorites(@Request() req) {
    return this.recipesService.getFavorites(req.user.id);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get recipe by ID' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe details' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  async getRecipeById(@Param('id') id: string) {
    return this.recipesService.getRecipeById(id);
  }

  @Get(':id/ingredients')
  @ApiOperation({ summary: 'Get recipe ingredients' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe ingredients' })
  async getRecipeIngredients(@Param('id') id: string) {
    return this.recipesService.getRecipeIngredients(id);
  }

  @Get(':id/variants')
  @ApiOperation({ summary: 'Get recipe variants' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe variants' })
  async getRecipeVariants(@Param('id') id: string) {
    return this.recipesService.getRecipeVariants(id);
  }

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create new recipe (Admin only)' })
  @ApiResponse({ status: 201, description: 'Recipe created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async createRecipe(@Body() createRecipeDto: CreateRecipeDto) {
    return this.recipesService.createRecipe(createRecipeDto);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe updated successfully' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async updateRecipe(
    @Param('id') id: string,
    @Body() updateRecipeDto: UpdateRecipeDto
  ) {
    return this.recipesService.updateRecipe(id, updateRecipeDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe deleted successfully' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async deleteRecipe(@Param('id') id: string) {
    return this.recipesService.deleteRecipe(id);
  }

  @Post(':id/ingredients')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add ingredient to recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Ingredient added successfully' })
  async addRecipeIngredient(
    @Param('id') id: string,
    @Body() addIngredientDto: AddIngredientDto
  ) {
    return this.recipesService.addRecipeIngredient(id, addIngredientDto);
  }

  @Delete(':id/ingredients/:ingredientId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove ingredient from recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiParam({ name: 'ingredientId', description: 'Ingredient ID' })
  @ApiResponse({ status: 200, description: 'Ingredient removed successfully' })
  async removeRecipeIngredient(
    @Param('id') id: string,
    @Param('ingredientId') ingredientId: string
  ) {
    return this.recipesService.removeRecipeIngredient(id, ingredientId);
  }

  @Post(':id/tags')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add tag to recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Tag added successfully' })
  async addRecipeTag(
    @Param('id') id: string,
    @Body() addTagDto: AddTagDto
  ) {
    return this.recipesService.addRecipeTag(id, addTagDto.tag_id);
  }

  @Delete(':id/tags/:tagId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove tag from recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiParam({ name: 'tagId', description: 'Tag ID' })
  @ApiResponse({ status: 200, description: 'Tag removed successfully' })
  async removeRecipeTag(
    @Param('id') id: string,
    @Param('tagId') tagId: string
  ) {
    return this.recipesService.removeRecipeTag(id, tagId);
  }

  // Favorites - Add/Remove
  @Post(':id/favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add recipe to favorites' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Added to favorites' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addFavorite(@Request() req, @Param('id') recipeId: string) {
    return this.recipesService.addFavorite(req.user.id, recipeId);
  }

  @Delete(':id/favorite')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Remove recipe from favorites' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Removed from favorites' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async removeFavorite(@Request() req, @Param('id') recipeId: string) {
    return this.recipesService.removeFavorite(req.user.id, recipeId);
  }
}