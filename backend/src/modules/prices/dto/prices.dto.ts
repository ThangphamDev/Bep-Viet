import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum, Min } from 'class-validator';

export class CreatePriceDto {
  @ApiProperty({ example: 'ingredient-uuid' })
  @IsString()
  ingredient_id: string;

  @ApiProperty({ example: 'BAC', enum: ['BAC', 'TRUNG', 'NAM'] })
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  region: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'kg' })
  @IsString()
  unit: string;

  @ApiProperty({ example: 50000 })
  @IsNumber()
  @Min(0)
  price_per_unit: number;

  @ApiProperty({ example: 'VND', required: false })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiProperty({ example: 'Chợ Bình Tây', required: false })
  @IsOptional()
  @IsString()
  source?: string;
}

export class UpdatePriceDto {
  @ApiProperty({ example: 'kg', required: false })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiProperty({ example: 50000, required: false })
  @IsOptional()
  @IsNumber()
  @Min(0)
  price_per_unit?: number;

  @ApiProperty({ example: 'VND', required: false })
  @IsOptional()
  @IsString()
  currency?: string;

  @ApiProperty({ example: 'Chợ Bình Tây', required: false })
  @IsOptional()
  @IsString()
  source?: string;
}
