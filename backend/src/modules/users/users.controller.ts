import { Controller, Get, Patch, Delete, Body, UseGuards, Request, Put, Post, Param, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators';
import { UsersService } from './users.service';
import { UpdateProfileDto, UserProfileDto, ChangePasswordDto } from './dto/users.dto';

@ApiTags('Users')
@Controller('users')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'User profile', type: UserProfileDto })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getProfile(@Request() req) {
    const user = await this.usersService.getProfile(req.user.id);
    return {
      success: true,
      data: user,
    };
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update current user profile' })
  @ApiResponse({ status: 200, description: 'Profile updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProfile(@Request() req, @Body() updateProfileDto: UpdateProfileDto) {
    return this.usersService.updateProfile(req.user.id, updateProfileDto);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Update user profile (alternative endpoint)' })
  @ApiResponse({ status: 200, description: 'Profile updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async updateProfileAlt(@Request() req, @Body() updateProfileDto: UpdateProfileDto) {
    return this.usersService.updateProfile(req.user.id, updateProfileDto);
  }

  @Put('change-password')
  @ApiOperation({ summary: 'Change user password' })
  @ApiResponse({ status: 200, description: 'Password changed successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 400, description: 'Invalid current password' })
  async changePassword(@Request() req, @Body() changePasswordDto: ChangePasswordDto) {
    await this.usersService.changePassword(req.user.id, changePasswordDto);
    return {
      success: true,
      message: 'Password changed successfully',
    };
  }

  @Delete('me')
  @ApiOperation({ summary: 'Delete current user account' })
  @ApiResponse({ status: 200, description: 'Account deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async deleteAccount(@Request() req) {
    await this.usersService.deleteAccount(req.user.id);
    return {
      success: true,
      message: 'Account deleted successfully',
    };
  }

  // ============ ADMIN ENDPOINTS ============

  @Get()
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get all users (Admin only)' })
  @ApiQuery({ name: 'search', required: false, description: 'Search by name or email' })
  @ApiQuery({ name: 'role', required: false, description: 'Filter by role' })
  @ApiQuery({ name: 'is_active', required: false, description: 'Filter by active status' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results' })
  @ApiQuery({ name: 'offset', required: false, description: 'Offset for pagination' })
  @ApiResponse({ status: 200, description: 'List of users' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async getAllUsers(@Query() filters: any) {
    return this.usersService.getAllUsers(filters);
  }

  @Get(':id')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get user by ID (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User profile', type: UserProfileDto })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUserById(@Param('id') id: string) {
    const user = await this.usersService.getUserById(id);
    return {
      success: true,
      data: user,
    };
  }

  @Get(':id/recipes')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Get user recipes (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'List of user recipes' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  async getUserRecipes(@Param('id') id: string) {
    return this.usersService.getUserRecipes(id);
  }

  @Post(':id/block')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Block user (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User blocked successfully' })
  @ApiResponse({ status: 400, description: 'User is already blocked' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async blockUser(@Param('id') id: string, @Request() req) {
    return this.usersService.blockUser(id, req.user.id);
  }

  @Post(':id/unblock')
  @Roles('ADMIN')
  @ApiOperation({ summary: 'Unblock user (Admin only)' })
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiResponse({ status: 200, description: 'User unblocked successfully' })
  @ApiResponse({ status: 400, description: 'User is already active' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - Admin role required' })
  @ApiResponse({ status: 404, description: 'User not found' })
  async unblockUser(@Param('id') id: string, @Request() req) {
    return this.usersService.unblockUser(id, req.user.id);
  }
}
