import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CommentsService } from './comments.service';
import { AddCommentDto, UpdateCommentDto } from './dto/comments.dto';

@ApiTags('Comments')
@Controller('comments')
export class CommentsController {
  constructor(private readonly commentsService: CommentsService) {}

  @Get('recipes/:recipeId')
  @ApiOperation({ summary: 'Get comments for recipe' })
  @ApiParam({ name: 'recipeId', description: 'Recipe ID' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results', example: 20 })
  @ApiQuery({ name: 'offset', required: false, description: 'Offset results', example: 0 })
  @ApiResponse({ status: 200, description: 'List of comments' })
  async getComments(
    @Param('recipeId') recipeId: string,
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    const parsedLimit = parseInt(limit || '20', 10) || 20;
    const parsedOffset = parseInt(offset || '0', 10) || 0;
    return this.commentsService.getComments(
      recipeId, 
      recipeType, 
      parsedLimit, 
      parsedOffset
    );
  }

  @Post('recipes/:recipeId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Add comment to recipe' })
  @ApiParam({ name: 'recipeId', description: 'Recipe ID' })
  @ApiQuery({ name: 'recipeType', enum: ['SYSTEM', 'COMMUNITY'], description: 'Recipe type' })
  @ApiResponse({ status: 201, description: 'Comment added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async addComment(
    @Param('recipeId') recipeId: string,
    @Query('recipeType') recipeType: 'SYSTEM' | 'COMMUNITY',
    @Request() req,
    @Body() addCommentDto: AddCommentDto
  ) {
    return this.commentsService.addComment(recipeId, recipeType, req.user.id, addCommentDto.content);
  }

  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update comment' })
  @ApiParam({ name: 'id', description: 'Comment ID' })
  @ApiResponse({ status: 200, description: 'Comment updated successfully' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateComment(
    @Param('id') id: string,
    @Request() req,
    @Body() updateCommentDto: UpdateCommentDto
  ) {
    return this.commentsService.updateComment(id, req.user.id, updateCommentDto.content);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete comment' })
  @ApiParam({ name: 'id', description: 'Comment ID' })
  @ApiResponse({ status: 200, description: 'Comment deleted successfully' })
  @ApiResponse({ status: 404, description: 'Comment not found' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteComment(
    @Param('id') id: string,
    @Request() req
  ) {
    return this.commentsService.deleteComment(id, req.user.id);
  }

  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Like/unlike comment' })
  @ApiParam({ name: 'id', description: 'Comment ID' })
  @ApiResponse({ status: 200, description: 'Comment like status updated' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async likeComment(
    @Param('id') id: string,
    @Request() req
  ) {
    return this.commentsService.likeComment(id, req.user.id);
  }

  @Get('my-comments')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get user comments' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results', example: 20 })
  @ApiQuery({ name: 'offset', required: false, description: 'Offset results', example: 0 })
  @ApiResponse({ status: 200, description: 'User comments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getUserComments(
    @Request() req,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    const parsedLimit = parseInt(limit || '20', 10) || 20;
    const parsedOffset = parseInt(offset || '0', 10) || 0;
    return this.commentsService.getUserComments(
      req.user.id, 
      parsedLimit, 
      parsedOffset
    );
  }

}
