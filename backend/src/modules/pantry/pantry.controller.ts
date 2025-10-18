import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { PantryService } from './pantry.service';
import { AddPantryItemDto, UpdatePantryItemDto, ConsumePantryItemDto } from './dto/pantry.dto';

@ApiTags('Pantry')
@Controller('pantry')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PantryController {
  constructor(private readonly pantryService: PantryService) {}

  @Get()
  @ApiOperation({ summary: 'Get user pantry items' })
  @ApiResponse({ status: 200, description: 'List of pantry items' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserPantry(@Request() req) {
    return this.pantryService.getUserPantry(req.user.id);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Get pantry statistics' })
  @ApiResponse({ status: 200, description: 'Pantry statistics' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getPantryStats(@Query('userId') userId: string) {
    return this.pantryService.getPantryStats(userId);
  }

  @Get('expiring')
  @ApiOperation({ summary: 'Get expiring items' })
  @ApiQuery({ name: 'days', required: false, description: 'Days ahead to check', example: 3 })
  @ApiResponse({ status: 200, description: 'List of expiring items' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getExpiringItems(
    @Query('userId') userId: string,
    @Query('days') days?: string
  ) {
    return this.pantryService.getExpiringItems(userId, parseInt(days || '3'));
  }

  @Get('expired')
  @ApiOperation({ summary: 'Get expired items' })
  @ApiResponse({ status: 200, description: 'List of expired items' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getExpiredItems(@Query('userId') userId: string) {
    return this.pantryService.getExpiredItems(userId);
  }

  @Get('suggestions')
  @ApiOperation({ summary: 'Get recipe suggestions based on pantry' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results', example: 10 })
  @ApiResponse({ status: 200, description: 'Recipe suggestions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getPantrySuggestions(
    @Query('userId') userId: string,
    @Query('limit') limit?: string
  ) {
    return this.pantryService.getPantrySuggestions(userId, parseInt(limit || '10'));
  }

  @Post()
  @ApiOperation({ summary: 'Add pantry item' })
  @ApiResponse({ status: 201, description: 'Pantry item added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addPantryItem(
    @Query('userId') userId: string,
    @Body() addPantryItemDto: AddPantryItemDto
  ) {
    return this.pantryService.addPantryItem(userId, addPantryItemDto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update pantry item' })
  @ApiParam({ name: 'id', description: 'Pantry item ID' })
  @ApiResponse({ status: 200, description: 'Pantry item updated successfully' })
  @ApiResponse({ status: 404, description: 'Pantry item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updatePantryItem(
    @Param('id') id: string,
    @Query('userId') userId: string,
    @Body() updatePantryItemDto: UpdatePantryItemDto
  ) {
    return this.pantryService.updatePantryItem(id, userId, updatePantryItemDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete pantry item' })
  @ApiParam({ name: 'id', description: 'Pantry item ID' })
  @ApiResponse({ status: 200, description: 'Pantry item deleted successfully' })
  @ApiResponse({ status: 404, description: 'Pantry item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deletePantryItem(
    @Param('id') id: string,
    @Query('userId') userId: string
  ) {
    return this.pantryService.deletePantryItem(id, userId);
  }

  @Post('consume')
  @ApiOperation({ summary: 'Consume pantry item' })
  @ApiResponse({ status: 200, description: 'Pantry item consumed successfully' })
  @ApiResponse({ status: 404, description: 'Insufficient quantity' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async consumePantryItem(
    @Query('userId') userId: string,
    @Body() consumePantryItemDto: ConsumePantryItemDto
  ) {
    return this.pantryService.consumePantryItem(
      userId,
      consumePantryItemDto.ingredient_id,
      consumePantryItemDto.quantity
    );
  }
}
