import { 
  Controller, 
  Post, 
  Body, 
  UseInterceptors, 
  UploadedFile,
  HttpException,
  HttpStatus,
  Query
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiConsumes, ApiBody, ApiQuery } from '@nestjs/swagger';
import { GeminiService, GeminiAnalysisResult } from './gemini.service';
import { AnalyzeImageDto } from './dto/gemini.dto';

@ApiTags('Gemini AI')
@Controller('gemini')
export class GeminiController {
  constructor(private readonly geminiService: GeminiService) {}

  @Post('analyze-image')
  @ApiOperation({ summary: 'Analyze image to detect ingredients using Gemini AI' })
  @ApiConsumes('multipart/form-data')
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
          description: 'Image file to analyze'
        }
      }
    }
  })
  @ApiResponse({ status: 200, description: 'Image analyzed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid image or API error' })
  @UseInterceptors(FileInterceptor('image'))
  async analyzeImage(@UploadedFile() file: any): Promise<{success: boolean; data: GeminiAnalysisResult; message: string}> {
    try {
      if (!file) {
        throw new HttpException('No image file provided', HttpStatus.BAD_REQUEST);
      }

      // Convert buffer to base64
      const base64Image = file.buffer.toString('base64');

      // Analyze with Gemini
      const analysis = await this.geminiService.analyzeIngredients(base64Image);

      return {
        success: true,
        data: analysis,
        message: 'Image analyzed successfully'
      };
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to analyze image',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Post('analyze-image-base64')
  @ApiOperation({ summary: 'Analyze base64 image to detect ingredients' })
  @ApiBody({ type: AnalyzeImageDto })
  @ApiResponse({ status: 200, description: 'Image analyzed successfully' })
  @ApiResponse({ status: 400, description: 'Invalid image or API error' })
  async analyzeImageBase64(@Body() analyzeImageDto: AnalyzeImageDto): Promise<{success: boolean; data: GeminiAnalysisResult; message: string}> {
    try {
      const { imageBase64 } = analyzeImageDto;

      if (!imageBase64) {
        throw new HttpException('No image data provided', HttpStatus.BAD_REQUEST);
      }

      // Remove data:image/jpeg;base64, prefix if present
      const base64Data = imageBase64.replace(/^data:image\/\w+;base64,/, '');

      // Analyze with Gemini
      const analysis = await this.geminiService.analyzeIngredients(base64Data);

      return {
        success: true,
        data: analysis,
        message: 'Image analyzed successfully'
      };
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to analyze image',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Post('suggest-from-ingredients')
  @ApiOperation({ summary: 'Get recipe suggestions from detected ingredients' })
  @ApiQuery({ name: 'region', required: false, description: 'Filter by region' })
  @ApiQuery({ name: 'limit', required: false, description: 'Limit results' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        ingredient_ids: {
          type: 'array',
          items: { type: 'string' },
          description: 'Array of ingredient IDs'
        }
      }
    }
  })
  @ApiResponse({ status: 200, description: 'Suggestions retrieved successfully' })
  async getSuggestionsFromIngredients(
    @Body() body: { ingredient_ids: string[] },
    @Query('region') region?: string,
    @Query('limit') limit?: string
  ) {
    try {
      const suggestions = await this.geminiService.getSuggestionsFromIngredients(
        body.ingredient_ids,
        region,
        parseInt(limit || '10')
      );

      return {
        success: true,
        data: suggestions,
        count: suggestions.length
      };
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to get suggestions',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
