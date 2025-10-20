import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsArray, IsOptional } from 'class-validator';

export class AnalyzeImageDto {
  @ApiProperty({
    description: 'Base64 encoded image data',
    example: 'data:image/jpeg;base64,/9j/4AAQSkZJRg...'
  })
  @IsString()
  @IsNotEmpty()
  imageBase64: string;
}

export class SuggestFromIngredientsDto {
  @ApiProperty({
    description: 'Array of ingredient IDs detected from image',
    example: ['uuid-1', 'uuid-2', 'uuid-3']
  })
  @IsArray()
  @IsNotEmpty()
  ingredient_ids: string[];

  @ApiProperty({
    description: 'Filter by region',
    example: 'NAM',
    required: false
  })
  @IsString()
  @IsOptional()
  region?: string;

  @ApiProperty({
    description: 'Limit number of results',
    example: 10,
    required: false
  })
  @IsOptional()
  limit?: number;
}
