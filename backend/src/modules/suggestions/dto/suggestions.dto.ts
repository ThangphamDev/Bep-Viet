import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsEnum, IsArray, Min, Max } from 'class-validator';

export class SearchSuggestionsDto {
  @ApiProperty({ example: 'NAM', enum: ['BAC', 'TRUNG', 'NAM'], required: false })
  @IsOptional()
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  region?: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'HA', enum: ['XUAN', 'HA', 'THU', 'DONG'], required: false })
  @IsOptional()
  @IsEnum(['XUAN', 'HA', 'THU', 'DONG'])
  season?: 'XUAN' | 'HA' | 'THU' | 'DONG';

  @ApiProperty({ example: 2, minimum: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  servings?: number;

  @ApiProperty({ example: 50000, minimum: 0, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  budget?: number;

  @ApiProperty({ example: 3, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  spice_pref?: number;

  @ApiProperty({ example: ['ingredient1', 'ingredient2'], required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  pantry_ids?: string[];

  @ApiProperty({ example: ['hai_san', 'thit_bo'], required: false })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  exclude_allergens?: string[];

  @ApiProperty({ example: 30, minimum: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  max_time?: number;

  @ApiProperty({ example: 'LUNCH', enum: ['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'], required: false })
  @IsOptional()
  @IsEnum(['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'])
  meal_type?: 'BREAKFAST' | 'LUNCH' | 'DINNER' | 'SNACK';
}
