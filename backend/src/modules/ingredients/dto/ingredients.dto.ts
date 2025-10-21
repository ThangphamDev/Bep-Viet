import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsBoolean, Min, IsObject } from 'class-validator';

export class CreateIngredientDto {
  @ApiProperty({ example: 'Cà chua' })
  @IsString()
  name: string;

  @ApiProperty({ example: 3, required: false })
  @IsOptional()
  @IsInt()
  category_id?: number;

  @ApiProperty({ example: 'kg' })
  @IsString()
  default_unit: string;

  @ApiProperty({ example: 7, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  shelf_life_days?: number;

  @ApiProperty({ 
    example: { substitutes: ['cà chua bi', 'cà chua cherry'] }, 
    required: false,
    description: 'JSON object containing ingredient substitutions'
  })
  @IsOptional()
  @IsObject()
  substitutions_json?: any;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  perishable?: boolean;

  @ApiProperty({ example: 'Cà chua tươi, ngon', required: false })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateIngredientDto {
  @ApiProperty({ example: 'Cà chua', required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ example: 3, required: false })
  @IsOptional()
  @IsInt()
  category_id?: number;

  @ApiProperty({ example: 'kg', required: false })
  @IsOptional()
  @IsString()
  default_unit?: string;

  @ApiProperty({ example: 7, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  shelf_life_days?: number;

  @ApiProperty({ 
    example: { substitutes: ['cà chua bi', 'cà chua cherry'] }, 
    required: false,
    description: 'JSON object containing ingredient substitutions'
  })
  @IsOptional()
  @IsObject()
  substitutions_json?: any;

  @ApiProperty({ example: true, required: false })
  @IsOptional()
  @IsBoolean()
  perishable?: boolean;

  @ApiProperty({ example: 'Cà chua tươi, ngon', required: false })
  @IsOptional()
  @IsString()
  notes?: string;
}
