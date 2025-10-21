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

  @Post('ai-suggest-chatbot')
  @ApiOperation({ 
    summary: '🤖 AI Chatbot - Recipe suggestions with conversational response',
    description: 'Gemini phân tích yêu cầu người dùng và trả về gợi ý dạng chatbot với lời khuyên chi tiết'
  })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['ingredient_ids'],
      properties: {
        ingredient_ids: {
          type: 'array',
          items: { type: 'string' },
          description: 'Array of ingredient IDs',
          example: ['uuid-1', 'uuid-2']
        },
        prompt: {
          type: 'string',
          description: 'User request (e.g., "cho bé ăn", "đậm vị", "nhanh gọn")',
          example: 'cho bé ăn'
        },
        region: {
          type: 'string',
          description: 'Region (BAC, TRUNG, NAM)',
          example: 'BAC'
        },
        spice_preference: {
          type: 'number',
          description: 'Spice level (0-4)',
          example: 0
        },
        limit: {
          type: 'number',
          description: 'Max suggestions',
          example: 7
        }
      }
    }
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Chatbot response with curated suggestions',
    schema: {
      example: {
        success: true,
        data: {
          chatResponse: 'Chào bạn! Em thấy bạn có gà, rau, trứng và muốn nấu cho bé...',
          suggestions: [
            {
              recipeId: 'uuid',
              recipeName: 'Cháo gà',
              matchReason: 'Cháo mềm nhũn, dễ tiêu hóa, rất phù hợp cho bé',
              advisory: 'Nấu nhừ thêm 10 phút, bỏ xương cẩn thận...',
              ingredientMatch: 95,
              missingIngredients: ['cà rốt'],
              tags: ['Cháo', 'Cho bé ăn']
            }
          ],
          generalAdvice: 'Với bé nhỏ, nên ưu tiên món luộc/hấp...'
        }
      }
    }
  })
  async aiSuggestChatbot(@Body() body: {
    ingredient_ids: string[];
    prompt?: string;
    region?: string;
    spice_preference?: number;
    limit?: number;
  }) {
    try {
      const result = await this.geminiService.aiSuggestChatbot({
        ingredient_ids: body.ingredient_ids,
        prompt: body.prompt,
        region: body.region,
        spice_preference: body.spice_preference,
        limit: body.limit || 7
      });

      return {
        success: true,
        data: result
      };
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to get AI chatbot suggestions',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }

  @Post('ai-suggest')
  @ApiOperation({ 
    summary: 'AI-powered recipe suggestions with intelligent filtering (OLD)',
    description: 'Analyzes user intent and returns personalized recipe suggestions based on ingredients, preferences, and context (e.g., "cho bé ăn", "đậm vị", etc.)'
  })
  @ApiBody({
    schema: {
      type: 'object',
      required: ['ingredient_ids'],
      properties: {
        ingredient_ids: {
          type: 'array',
          items: { type: 'string' },
          description: 'Array of ingredient IDs detected from image',
          example: ['uuid-1', 'uuid-2']
        },
        prompt: {
          type: 'string',
          description: 'User request/prompt (e.g., "cho bé ăn", "đậm vị", "nhanh gọn")',
          example: 'cho bé ăn'
        },
        region: {
          type: 'string',
          description: 'Filter by region (BAC, TRUNG, NAM)',
          example: 'BAC'
        },
        spice_preference: {
          type: 'number',
          description: 'Spice preference level (0-4)',
          example: 1
        },
        limit: {
          type: 'number',
          description: 'Limit number of results',
          example: 10
        }
      }
    }
  })
  @ApiResponse({ 
    status: 200, 
    description: 'AI suggestions retrieved successfully with requestMatchScore and ingredientMatchScore' 
  })
  async aiSuggest(@Body() body: {
    ingredient_ids: string[];
    prompt?: string;
    region?: string;
    spice_preference?: number;
    limit?: number;
  }) {
    try {
      const suggestions = await this.geminiService.aiSuggest({
        ingredient_ids: body.ingredient_ids,
        prompt: body.prompt,
        region: body.region,
        spice_preference: body.spice_preference,
        limit: body.limit || 10
      });

      return {
        success: true,
        data: suggestions,
        count: suggestions.length
      };
    } catch (error) {
      throw new HttpException(
        error.message || 'Failed to get AI suggestions',
        HttpStatus.INTERNAL_SERVER_ERROR
      );
    }
  }
}
