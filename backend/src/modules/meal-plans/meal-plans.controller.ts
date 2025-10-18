import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { MealPlansService } from './meal-plans.service';
import { CreateMealPlanDto, AddMealDto, GenerateMealPlanDto, UpdateMealPlanDto } from './dto/meal-plans.dto';

@ApiTags('Meal Plans')
@Controller('meal-plans')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class MealPlansController {
  constructor(private readonly mealPlansService: MealPlansService) {}

  @Get()
  @ApiOperation({ summary: 'Get user meal plans' })
  @ApiResponse({ status: 200, description: 'List of meal plans' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserMealPlans(@Request() req) {
    return this.mealPlansService.getUserMealPlans(req.user.id);
  }

  @Get(':userId/:weekStartDate')
  @ApiOperation({ summary: 'Get meal plan by week' })
  @ApiParam({ name: 'userId', description: 'User ID' })
  @ApiParam({ name: 'weekStartDate', description: 'Week start date (YYYY-MM-DD)' })
  @ApiResponse({ status: 200, description: 'Meal plan details' })
  @ApiResponse({ status: 404, description: 'Meal plan not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getMealPlan(
    @Param('userId') userId: string,
    @Param('weekStartDate') weekStartDate: string
  ) {
    return this.mealPlansService.getMealPlan(userId, weekStartDate);
  }

  @Post()
  @ApiOperation({ summary: 'Create meal plan' })
  @ApiResponse({ status: 201, description: 'Meal plan created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createMealPlan(
    @Query('userId') userId: string,
    @Body() createMealPlanDto: CreateMealPlanDto
  ) {
    return this.mealPlansService.createMealPlan(userId, createMealPlanDto);
  }

  @Post('generate')
  @ApiOperation({ summary: 'Generate automatic meal plan' })
  @ApiResponse({ status: 200, description: 'Meal plan generated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generateMealPlan(
    @Query('userId') userId: string,
    @Body() generateMealPlanDto: GenerateMealPlanDto
  ) {
    return this.mealPlansService.generateMealPlan(userId, generateMealPlanDto);
  }

  @Post(':mealPlanId/meals')
  @ApiOperation({ summary: 'Add meal to plan' })
  @ApiParam({ name: 'mealPlanId', description: 'Meal plan ID' })
  @ApiResponse({ status: 201, description: 'Meal added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addMealToPlan(
    @Param('mealPlanId') mealPlanId: string,
    @Body() addMealDto: AddMealDto
  ) {
    return this.mealPlansService.addMealToPlan(mealPlanId, addMealDto);
  }

  @Delete(':mealPlanId/meals/:date/:mealSlot')
  @ApiOperation({ summary: 'Remove meal from plan' })
  @ApiParam({ name: 'mealPlanId', description: 'Meal plan ID' })
  @ApiParam({ name: 'date', description: 'Date (YYYY-MM-DD)' })
  @ApiParam({ name: 'mealSlot', description: 'Meal slot (BREAKFAST, LUNCH, DINNER)' })
  @ApiResponse({ status: 200, description: 'Meal removed successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async removeMealFromPlan(
    @Param('mealPlanId') mealPlanId: string,
    @Param('date') date: string,
    @Param('mealSlot') mealSlot: string
  ) {
    return this.mealPlansService.removeMealFromPlan(mealPlanId, date, mealSlot);
  }

  @Put(':mealPlanId')
  @ApiOperation({ summary: 'Update meal plan' })
  @ApiParam({ name: 'mealPlanId', description: 'Meal plan ID' })
  @ApiResponse({ status: 200, description: 'Meal plan updated successfully' })
  @ApiResponse({ status: 404, description: 'Meal plan not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateMealPlan(
    @Param('mealPlanId') mealPlanId: string,
    @Body() updateMealPlanDto: UpdateMealPlanDto
  ) {
    return this.mealPlansService.updateMealPlan(mealPlanId, updateMealPlanDto);
  }

  @Delete(':mealPlanId')
  @ApiOperation({ summary: 'Delete meal plan' })
  @ApiParam({ name: 'mealPlanId', description: 'Meal plan ID' })
  @ApiResponse({ status: 200, description: 'Meal plan deleted successfully' })
  @ApiResponse({ status: 404, description: 'Meal plan not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteMealPlan(@Param('mealPlanId') mealPlanId: string) {
    return this.mealPlansService.deleteMealPlan(mealPlanId);
  }
}