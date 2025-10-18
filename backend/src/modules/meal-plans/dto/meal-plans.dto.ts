import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsEnum, IsDateString, Min, Max } from 'class-validator';

export class CreateMealPlanDto {
  @ApiProperty({ example: '2024-01-15' })
  @IsDateString()
  week_start_date: string;

  @ApiProperty({ example: 'Tuần này sẽ ăn nhiều rau', required: false })
  @IsOptional()
  @IsString()
  note?: string;
}

export class AddMealDto {
  @ApiProperty({ example: '2024-01-15' })
  @IsDateString()
  date: string;

  @ApiProperty({ example: 'LUNCH', enum: ['BREAKFAST', 'LUNCH', 'DINNER'] })
  @IsEnum(['BREAKFAST', 'LUNCH', 'DINNER'])
  meal_slot: 'BREAKFAST' | 'LUNCH' | 'DINNER';

  @ApiProperty({ example: 'recipe-uuid' })
  @IsString()
  recipe_id: string;

  @ApiProperty({ example: 'NAM', enum: ['BAC', 'TRUNG', 'NAM'], required: false })
  @IsOptional()
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  variant_region?: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 2, minimum: 1 })
  @IsInt()
  @Min(1)
  servings: number;
}

export class GenerateMealPlanDto {
  @ApiProperty({ example: '2024-01-15' })
  @IsDateString()
  week_start: string;

  @ApiProperty({ example: 'NAM', enum: ['BAC', 'TRUNG', 'NAM'] })
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  region: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 50000, minimum: 0 })
  @IsInt()
  @Min(0)
  budget_per_meal: number;

  @ApiProperty({ example: 2, minimum: 1 })
  @IsInt()
  @Min(1)
  servings: number;

  @ApiProperty({ example: { max_time: 60, no_repeat: true }, required: false })
  @IsOptional()
  constraints?: {
    max_time?: number;
    no_repeat?: boolean;
    nutrition_balance?: boolean;
  };
}

export class UpdateMealPlanDto {
  @ApiProperty({ example: 'Tuần này sẽ ăn nhiều rau', required: false })
  @IsOptional()
  @IsString()
  note?: string;
}
