import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { CommentsService } from './comments.service';
import { AddCommentDto, UpdateCommentDto, ReportCommentDto } from './dto/comments.dto';

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
    return this.commentsService.getComments(
      recipeId, 
      recipeType, 
      parseInt(limit || '20'), 
      parseInt(offset || '0')
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
    @Query('userId') userId: string,
    @Body() addCommentDto: AddCommentDto
  ) {
    return this.commentsService.addComment(recipeId, recipeType, userId, addCommentDto.content);
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
    @Query('userId') userId: string,
    @Body() updateCommentDto: UpdateCommentDto
  ) {
    return this.commentsService.updateComment(id, userId, updateCommentDto.content);
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
    @Query('userId') userId: string
  ) {
    return this.commentsService.deleteComment(id, userId);
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
    @Query('userId') userId: string
  ) {
    return this.commentsService.likeComment(id, userId);
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
    @Query('userId') userId: string,
    @Query('limit') limit?: string,
    @Query('offset') offset?: string
  ) {
    return this.commentsService.getUserComments(
      userId, 
      parseInt(limit || '20'), 
      parseInt(offset || '0')
    );
  }

  @Post(':id/report')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Report comment' })
  @ApiParam({ name: 'id', description: 'Comment ID' })
  @ApiResponse({ status: 200, description: 'Comment reported successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async reportComment(
    @Param('id') id: string,
    @Query('userId') userId: string,
    @Body() reportCommentDto: ReportCommentDto
  ) {
    return this.commentsService.reportComment(id, userId, reportCommentDto.reason);
  }

  @Get('moderation/reported')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get reported comments' })
  @ApiResponse({ status: 200, description: 'List of reported comments' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async getReportedComments() {
    return this.commentsService.getReportedComments();
  }

  @Put('moderation/:reportId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Moderate reported comment' })
  @ApiParam({ name: 'reportId', description: 'Report ID' })
  @ApiResponse({ status: 200, description: 'Comment moderated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async moderateComment(
    @Param('reportId') reportId: string,
    @Query('adminUserId') adminUserId: string,
    @Body('action') action: string,
    @Body('note') note?: string
  ) {
    return this.commentsService.moderateComment(reportId, adminUserId, action, note);
  }
}
