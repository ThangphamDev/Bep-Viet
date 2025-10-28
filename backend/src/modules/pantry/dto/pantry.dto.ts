import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsDateString, Min, MaxLength } from 'class-validator';
import { Transform } from 'class-transformer';

export class AddPantryItemDto {
  @ApiProperty({ example: 'ingredient-uuid' })
  @IsString()
  @MaxLength(36, { message: 'ingredient_id must not exceed 36 characters (UUID format)' })
  @Transform(({ value }) => value?.trim())
  ingredient_id: string;

  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(0)
  quantity: number;

  @ApiProperty({ example: 'g' })
  @IsString()
  unit: string;

  @ApiProperty({ example: '2024-01-20', required: false })
  @IsOptional()
  @IsDateString()
  expire_date?: string;

  @ApiProperty({ example: 'fridge', required: false })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiProperty({ example: 'BATCH001', required: false })
  @IsOptional()
  @IsString()
  batch_code?: string;
}

export class UpdatePantryItemDto {
  @ApiProperty({ example: 500, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  quantity?: number;

  @ApiProperty({ example: 'g', required: false })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiProperty({ example: '2024-01-20', required: false })
  @IsOptional()
  @IsDateString()
  expire_date?: string;

  @ApiProperty({ example: 'fridge', required: false })
  @IsOptional()
  @IsString()
  location?: string;

  @ApiProperty({ example: 'BATCH001', required: false })
  @IsOptional()
  @IsString()
  batch_code?: string;
}

export class ConsumePantryItemDto {
  @ApiProperty({ example: 'ingredient-uuid' })
  @IsString()
  @MaxLength(36, { message: 'ingredient_id must not exceed 36 characters (UUID format)' })
  @Transform(({ value }) => value?.trim())
  ingredient_id: string;

  @ApiProperty({ example: 200 })
  @IsInt()
  @Min(1)
  quantity: number;
}
