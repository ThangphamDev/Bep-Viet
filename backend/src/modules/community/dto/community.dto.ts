import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsEnum, IsArray, ValidateNested, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateCommunityRecipeDto {
  @ApiProperty({ example: 'Phở Bò Hà Nội' })
  @IsString()
  title: string;

  @ApiProperty({ example: 'BAC', enum: ['BAC', 'TRUNG', 'NAM'] })
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  region: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'Món phở ngon nhất Hà Nội' })
  @IsString()
  description_md: string;

  @ApiProperty({ example: 'TRUNG_BINH', enum: ['DE', 'TRUNG_BINH', 'KHO'] })
  @IsEnum(['DE', 'TRUNG_BINH', 'KHO'])
  difficulty: 'DE' | 'TRUNG_BINH' | 'KHO';

  @ApiProperty({ example: 60 })
  @IsInt()
  @Min(1)
  time_min: number;

  @ApiProperty({ example: 50000, required: false })
  @IsOptional()
  @IsInt()
  cost_hint?: number;

  @ApiProperty({ 
    example: [
      { name: 'Bánh phở', quantity: '200g', note: 'Loại tươi' },
      { name: 'Thịt bò', quantity: '150g', note: 'Thăn bò' }
    ]
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CommunityRecipeIngredientDto)
  ingredients: CommunityRecipeIngredientDto[];

  @ApiProperty({ 
    example: [
      { order_no: 1, content_md: 'Chuẩn bị nguyên liệu' },
      { order_no: 2, content_md: 'Nấu nước dùng' }
    ]
  })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CommunityRecipeStepDto)
  steps: CommunityRecipeStepDto[];
}

export class CommunityRecipeIngredientDto {
  @ApiProperty({ example: 'Bánh phở' })
  @IsString()
  name: string;

  @ApiProperty({ example: '200g' })
  @IsString()
  quantity: string;

  @ApiProperty({ example: 'Loại tươi', required: false })
  @IsOptional()
  @IsString()
  note?: string;
}

export class CommunityRecipeStepDto {
  @ApiProperty({ example: 1 })
  @IsInt()
  @Min(1)
  order_no: number;

  @ApiProperty({ example: 'Chuẩn bị nguyên liệu và nước dùng' })
  @IsString()
  content_md: string;
}

export class AddCommentDto {
  @ApiProperty({ example: 'Món này rất ngon!' })
  @IsString()
  content: string;
}

export class AddRatingDto {
  @ApiProperty({ example: 5, minimum: 1, maximum: 5 })
  @IsInt()
  @Min(1)
  @Max(5)
  stars: number;
}
