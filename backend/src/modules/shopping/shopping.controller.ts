import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { ShoppingService } from './shopping.service';
import { CreateShoppingListDto, AddItemDto, ShareListDto } from './dto/shopping.dto';

@ApiTags('Shopping')
@Controller('shopping')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ShoppingController {
  constructor(private readonly shoppingService: ShoppingService) {}

  @Get('lists')
  @ApiOperation({ summary: 'Get user shopping lists' })
  @ApiResponse({ status: 200, description: 'List of shopping lists' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserShoppingLists(@Query('userId') userId: string) {
    return this.shoppingService.getUserShoppingLists(userId);
  }

  @Get('sections')
  @ApiOperation({ summary: 'Get store sections' })
  @ApiResponse({ status: 200, description: 'List of store sections' })
  async getStoreSections() {
    return this.shoppingService.getStoreSections();
  }

  @Get('lists/:id')
  @ApiOperation({ summary: 'Get shopping list details' })
  @ApiParam({ name: 'id', description: 'Shopping list ID' })
  @ApiResponse({ status: 200, description: 'Shopping list details' })
  @ApiResponse({ status: 404, description: 'Shopping list not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getShoppingList(
    @Param('id') id: string,
    @Query('userId') userId: string
  ) {
    return this.shoppingService.getShoppingList(id, userId);
  }

  @Post('lists')
  @ApiOperation({ summary: 'Create shopping list' })
  @ApiResponse({ status: 201, description: 'Shopping list created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createShoppingList(
    @Query('userId') userId: string,
    @Body() createShoppingListDto: CreateShoppingListDto
  ) {
    return this.shoppingService.createShoppingList(userId, createShoppingListDto);
  }

  @Post('lists/:id/items')
  @ApiOperation({ summary: 'Add item to shopping list' })
  @ApiParam({ name: 'id', description: 'Shopping list ID' })
  @ApiResponse({ status: 201, description: 'Item added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addItemToList(
    @Param('id') id: string,
    @Body() addItemDto: AddItemDto
  ) {
    return this.shoppingService.addItemToList(id, addItemDto);
  }

  @Put('lists/:id/items/:itemId/check')
  @ApiOperation({ summary: 'Toggle item checked status' })
  @ApiParam({ name: 'id', description: 'Shopping list ID' })
  @ApiParam({ name: 'itemId', description: 'Item ID' })
  @ApiResponse({ status: 200, description: 'Item status updated successfully' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateItemStatus(
    @Param('id') id: string,
    @Param('itemId') itemId: string,
    @Body('checked') isChecked: boolean
  ) {
    return this.shoppingService.updateItemStatus(id, itemId, isChecked);
  }

  @Delete('lists/:id/items/:itemId')
  @ApiOperation({ summary: 'Remove item from shopping list' })
  @ApiParam({ name: 'id', description: 'Shopping list ID' })
  @ApiParam({ name: 'itemId', description: 'Item ID' })
  @ApiResponse({ status: 200, description: 'Item removed successfully' })
  @ApiResponse({ status: 404, description: 'Item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async removeItemFromList(
    @Param('id') id: string,
    @Param('itemId') itemId: string
  ) {
    return this.shoppingService.removeItemFromList(id, itemId);
  }

  @Post('generate-from-meal-plan')
  @ApiOperation({ summary: 'Generate shopping list from meal plan' })
  @ApiResponse({ status: 200, description: 'Shopping list generated successfully' })
  @ApiResponse({ status: 404, description: 'Meal plan not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generateFromMealPlan(
    @Query('userId') userId: string,
    @Body('meal_plan_id') mealPlanId: string,
    @Body('include_pantry') includePantry?: boolean
  ) {
    return this.shoppingService.generateFromMealPlan(userId, mealPlanId, includePantry);
  }

  @Post('lists/:id/share')
  @ApiOperation({ summary: 'Share shopping list' })
  @ApiParam({ name: 'id', description: 'Shopping list ID' })
  @ApiResponse({ status: 200, description: 'Invitation sent successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async shareList(
    @Param('id') id: string,
    @Query('userId') userId: string,
    @Body() shareListDto: ShareListDto
  ) {
    return this.shoppingService.shareList(id, userId, shareListDto);
  }

  @Post('accept-invitation')
  @ApiOperation({ summary: 'Accept shopping list invitation' })
  @ApiResponse({ status: 200, description: 'Invitation accepted successfully' })
  @ApiResponse({ status: 404, description: 'Invalid invitation' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async acceptInvitation(
    @Body('token') token: string,
    @Query('userId') userId: string
  ) {
    return this.shoppingService.acceptInvitation(token, userId);
  }
}
