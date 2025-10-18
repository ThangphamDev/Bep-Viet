import { Controller, Post, Get, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { SuggestionsService } from './suggestions.service';
import { SearchSuggestionsDto } from './dto/suggestions.dto';

@ApiTags('Suggestions')
@Controller('suggestions')
export class SuggestionsController {
  constructor(private readonly suggestionsService: SuggestionsService) {}

  @Post('search')
  @ApiOperation({ summary: 'Search recipe suggestions' })
  @ApiResponse({ status: 200, description: 'Recipe suggestions' })
  async searchSuggestions(@Body() searchParams: SearchSuggestionsDto) {
    return this.suggestionsService.searchSuggestions(searchParams);
  }

  @Get('pantry')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get suggestions based on pantry items' })
  @ApiResponse({ status: 200, description: 'Pantry-based suggestions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSuggestionsByPantry(
    @Query('userId') userId: string,
    @Query('limit') limit?: string
  ) {
    return this.suggestionsService.getSuggestionsByPantry(userId, parseInt(limit || '10'));
  }
}