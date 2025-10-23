import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request, UseInterceptors, UploadedFile } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { CommunityService } from './community.service';
import { CreateCommunityRecipeDto, UpdateCommunityRecipeDto, AddCommentDto, AddRatingDto } from './dto/community.dto';

@ApiTags('Community')
@Controller('community')
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Get('recipes')
  @ApiOperation({ summary: 'Get all community recipes' })
  @ApiResponse({ status: 200, description: 'List of community recipes' })
  async getAllCommunityRecipes(@Query() filters: any) {
    return this.communityService.getAllCommunityRecipes(filters);
  }

  @Get('recipes/featured')
  @ApiOperation({ summary: 'Get featured community recipes' })
  @ApiResponse({ status: 200, description: 'List of featured recipes' })
  async getFeaturedRecipes(@Query('limit') limit?: string) {
    const parsedLimit = parseInt(limit || '10', 10);
    return this.communityService.getFeaturedRecipes(isNaN(parsedLimit) ? 10 : parsedLimit);
  }

  @Get('recipes/:id')
  @ApiOperation({ summary: 'Get community recipe details' })
  @ApiParam({ name: 'id', description: 'Community recipe ID' })
  @ApiResponse({ status: 200, description: 'Community recipe details' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  async getCommunityRecipeById(@Param('id') id: string) {
    return this.communityService.getCommunityRecipeById(id);
  }

  @Post('recipes')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create community recipe' })
  @ApiResponse({ status: 201, description: 'Community recipe created successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createCommunityRecipe(
    @Request() req,
    @Body() createCommunityRecipeDto: CreateCommunityRecipeDto
  ) {
    return this.communityService.createCommunityRecipe(req.user.id, createCommunityRecipeDto);
  }

  @Post('recipes/:id/comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add comment to recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Comment added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addComment(
    @Param('id') id: string,
    @Request() req,
    @Body() addCommentDto: AddCommentDto
  ) {
    return this.communityService.addComment(id, 'COMMUNITY', req.user.id, addCommentDto.content);
  }

  @Post('recipes/:id/ratings')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Rate recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 201, description: 'Rating added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addRating(
    @Param('id') id: string,
    @Request() req,
    @Body() addRatingDto: AddRatingDto
  ) {
    return this.communityService.addRating(id, 'COMMUNITY', req.user.id, addRatingDto.stars);
  }

  @Get('my-recipes')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user community recipes' })
  @ApiResponse({ status: 200, description: 'User community recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserCommunityRecipes(@Request() req) {
    return this.communityService.getUserCommunityRecipes(req.user.id);
  }

  @Get('moderation/pending')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get pending recipes for moderation' })
  @ApiResponse({ status: 200, description: 'List of pending recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getPendingRecipes() {
    return this.communityService.getPendingRecipes();
  }

  @Put('moderation/:id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Moderate community recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe moderated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async moderateRecipe(
    @Param('id') id: string,
    @Request() req,
    @Body('action') action: string,
    @Body('note') note?: string
  ) {
    return this.communityService.moderateRecipe(id, req.user.id, action, note);
  }

  @Post('recipes/:id/promote-to-official')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Promote community recipe to official recipe (Admin only)' })
  @ApiParam({ name: 'id', description: 'Community Recipe ID' })
  @ApiQuery({ name: 'meal_type', required: false, enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'], description: 'Meal type for the official recipe (default: LUNCH)' })
  @ApiResponse({ status: 200, description: 'Recipe promoted successfully', schema: {
    example: {
      success: true,
      message: 'Community recipe promoted to official recipe successfully',
      data: {
        communityRecipeId: 'uuid-1',
        newRecipeId: 'uuid-2',
        recipeName: 'Phở Bò Hà Nội'
      }
    }
  }})
  @ApiResponse({ status: 400, description: 'Recipe already promoted or not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async promoteToOfficialRecipe(
    @Param('id') id: string,
    @Request() req,
    @Query('meal_type') mealType?: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK'
  ) {
    return this.communityService.promoteToOfficialRecipe(id, req.user.id, mealType || 'LUNCH');
  }

  @Put('recipes/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update community recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the author' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  async updateRecipe(
    @Param('id') id: string,
    @Request() req,
    @Body() updateCommunityRecipeDto: UpdateCommunityRecipeDto
  ) {
    return this.communityService.updateCommunityRecipe(id, req.user.id, updateCommunityRecipeDto);
  }

  @Delete('recipes/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete community recipe' })
  @ApiParam({ name: 'id', description: 'Recipe ID' })
  @ApiResponse({ status: 200, description: 'Recipe deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Not the author' })
  @ApiResponse({ status: 404, description: 'Recipe not found' })
  async deleteRecipe(@Param('id') id: string, @Request() req) {
    return this.communityService.deleteCommunityRecipe(id, req.user.id);
  }

  @Post('upload-image')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Upload image for community recipe' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
          description: 'Image file to upload'
        }
      }
    }
  })
  @ApiResponse({ status: 200, description: 'Image uploaded successfully' })
  @ApiResponse({ status: 400, description: 'Invalid image file' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @UseInterceptors(FileInterceptor('image'))
  async uploadImage(@UploadedFile() file: any) {
    if (!file) {
      return {
        success: false,
        message: 'No image file provided'
      };
    }

    // Convert to base64 for easy storage/transmission
    const base64Image = file.buffer.toString('base64');
    const imageUrl = `data:${file.mimetype};base64,${base64Image}`;

    return {
      success: true,
      data: {
        imageUrl: imageUrl,
        mimetype: file.mimetype,
        size: file.size
      },
      message: 'Image uploaded successfully'
    };
  }
}
