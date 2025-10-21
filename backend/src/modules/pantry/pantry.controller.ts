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
  async getPantryStats(@Request() req) {
    return this.pantryService.getPantryStats(req.user.id);
  }

  @Get('expiring')
  @ApiOperation({ summary: 'Get expiring items' })
  @ApiQuery({ name: 'days', required: false, description: 'Days ahead to check', example: 3 })
  @ApiResponse({ status: 200, description: 'List of expiring items' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getExpiringItems(
    @Request() req,
    @Query('days') days?: string
  ) {
    return this.pantryService.getExpiringItems(req.user.id, parseInt(days || '3'));
  }

  @Get('expired')
  @ApiOperation({ summary: 'Get expired items' })
  @ApiResponse({ status: 200, description: 'List of expired items' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getExpiredItems(@Request() req) {
    return this.pantryService.getExpiredItems(req.user.id);
  }

  @Get('suggestions')
  @ApiOperation({ summary: 'Get recipe suggestions based on pantry' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results', example: 10 })
  @ApiResponse({ status: 200, description: 'Recipe suggestions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getPantrySuggestions(
    @Request() req,
    @Query('limit') limit?: string
  ) {
    return this.pantryService.getPantrySuggestions(req.user.id, parseInt(limit || '10'));
  }

  @Post()
  @ApiOperation({ summary: 'Add pantry item' })
  @ApiResponse({ status: 201, description: 'Pantry item added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addPantryItem(
    @Request() req,
    @Body() addPantryItemDto: AddPantryItemDto
  ) {
    return this.pantryService.addPantryItem(req.user.id, addPantryItemDto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Update pantry item' })
  @ApiParam({ name: 'id', description: 'Pantry item ID' })
  @ApiResponse({ status: 200, description: 'Pantry item updated successfully' })
  @ApiResponse({ status: 404, description: 'Pantry item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updatePantryItem(
    @Param('id') id: string,
    @Request() req,
    @Body() updatePantryItemDto: UpdatePantryItemDto
  ) {
    return this.pantryService.updatePantryItem(id, req.user.id, updatePantryItemDto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete pantry item' })
  @ApiParam({ name: 'id', description: 'Pantry item ID' })
  @ApiResponse({ status: 200, description: 'Pantry item deleted successfully' })
  @ApiResponse({ status: 404, description: 'Pantry item not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deletePantryItem(
    @Param('id') id: string,
    @Request() req
  ) {
    return this.pantryService.deletePantryItem(id, req.user.id);
  }

  @Post('consume')
  @ApiOperation({ summary: 'Consume pantry item' })
  @ApiResponse({ status: 200, description: 'Pantry item consumed successfully' })
  @ApiResponse({ status: 404, description: 'Insufficient quantity' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async consumePantryItem(
    @Request() req,
    @Body() consumePantryItemDto: ConsumePantryItemDto
  ) {
    return this.pantryService.consumePantryItem(
      req.user.id,
      consumePantryItemDto.ingredient_id,
      consumePantryItemDto.quantity
    );
  }
}
