import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsEnum, Min, Max, IsJSON } from 'class-validator';

export class CreateRecipeDto {
  @ApiProperty({ example: 'Cơm tấm' })
  @IsString()
  name_vi: string;

  @ApiProperty({ example: 'Broken Rice', required: false })
  @IsOptional()
  @IsString()
  name_en?: string;

  @ApiProperty({ example: 'LUNCH', enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'] })
  @IsEnum(['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'])
  meal_type: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';

  @ApiProperty({ example: 2, minimum: 1, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  difficulty?: number;

  @ApiProperty({ example: 30, minimum: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  cook_time_min?: number;

  @ApiProperty({ example: 'Miền Nam', required: false })
  @IsOptional()
  @IsString()
  region?: string;

  @ApiProperty({ example: 'NAM', enum: ['BAC', 'TRUNG', 'NAM'], required: false })
  @IsOptional()
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  base_region?: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'TRUYEN_THONG', enum: ['TRUYEN_THONG', 'HIEN_DAI', 'FUSION'], required: false })
  @IsOptional()
  @IsEnum(['TRUYEN_THONG', 'HIEN_DAI', 'FUSION'])
  authenticity?: 'TRUYEN_THONG' | 'HIEN_DAI' | 'FUSION';

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  spice_level?: number;

  @ApiProperty({ example: 3, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  saltiness?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  hardness?: number;

  @ApiProperty({ example: 'https://example.com/image.jpg', required: false })
  @IsOptional()
  @IsString()
  image_url?: string;

  @ApiProperty({ example: '# Cách làm\n1. Nấu cơm...', required: false })
  @IsOptional()
  @IsString()
  instructions_md?: string;

  @ApiProperty({ example: '{"calories": 500, "protein": 20}', required: false })
  @IsOptional()
  @IsJSON()
  nutrition_json?: string;

  @ApiProperty({ example: 'user-uuid', required: false })
  @IsOptional()
  @IsString()
  author_id?: string;
}

export class UpdateRecipeDto {
  @ApiProperty({ example: 'Cơm tấm', required: false })
  @IsOptional()
  @IsString()
  name_vi?: string;

  @ApiProperty({ example: 'Broken Rice', required: false })
  @IsOptional()
  @IsString()
  name_en?: string;

  @ApiProperty({ example: 'LUNCH', enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'], required: false })
  @IsOptional()
  @IsEnum(['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'])
  meal_type?: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';

  @ApiProperty({ example: 2, minimum: 1, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  difficulty?: number;

  @ApiProperty({ example: 30, minimum: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  cook_time_min?: number;

  @ApiProperty({ example: 'Miền Nam', required: false })
  @IsOptional()
  @IsString()
  region?: string;

  @ApiProperty({ example: 'NAM', enum: ['BAC', 'TRUNG', 'NAM'], required: false })
  @IsOptional()
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  base_region?: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'TRUYEN_THONG', enum: ['TRUYEN_THONG', 'HIEN_DAI', 'FUSION'], required: false })
  @IsOptional()
  @IsEnum(['TRUYEN_THONG', 'HIEN_DAI', 'FUSION'])
  authenticity?: 'TRUYEN_THONG' | 'HIEN_DAI' | 'FUSION';

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  spice_level?: number;

  @ApiProperty({ example: 3, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  saltiness?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  hardness?: number;

  @ApiProperty({ example: 'https://example.com/image.jpg', required: false })
  @IsOptional()
  @IsString()
  image_url?: string;

  @ApiProperty({ example: '# Cách làm\n1. Nấu cơm...', required: false })
  @IsOptional()
  @IsString()
  instructions_md?: string;

  @ApiProperty({ example: '{"calories": 500, "protein": 20}', required: false })
  @IsOptional()
  @IsJSON()
  nutrition_json?: string;
}

export class AddIngredientDto {
  @ApiProperty({ example: 'ingredient-uuid' })
  @IsString()
  ingredient_id: string;

  @ApiProperty({ example: 200 })
  @IsInt()
  @Min(0)
  quantity: number;

  @ApiProperty({ example: 'g' })
  @IsString()
  unit: string;

  @ApiProperty({ example: 'Thịt heo nướng', required: false })
  @IsOptional()
  @IsString()
  note?: string;
}

export class AddTagDto {
  @ApiProperty({ example: 'tag-uuid' })
  @IsString()
  tag_id: string;
}
