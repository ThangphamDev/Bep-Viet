import { Controller, Post, Get, Body, Query, UseGuards, Request } from '@nestjs/common';
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
    try {
      const result = await this.suggestionsService.searchSuggestions(searchParams);
      return result;
    } catch (error) {
      console.error('Suggestions API error:', error);
      return {
        success: false,
        error: error.message,
        data: []
      };
    }
  }

  @Get('pantry')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get suggestions based on pantry items' })
  @ApiResponse({ status: 200, description: 'Pantry-based suggestions' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getSuggestionsByPantry(
    @Request() req,
    @Query('limit') limit?: string
  ) {
    return this.suggestionsService.getSuggestionsByPantry(req.user.id, parseInt(limit || '10'));
  }
}