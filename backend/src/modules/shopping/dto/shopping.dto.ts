import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsInt, IsEnum, IsEmail, Min } from 'class-validator';

export class CreateShoppingListDto {
  @ApiProperty({ example: 'Danh sách mua sắm tuần này' })
  @IsString()
  title: string;

  @ApiProperty({ example: '2024-01-15 to 2024-01-21', required: false })
  @IsOptional()
  @IsString()
  week_range?: string;

  @ApiProperty({ example: false, required: false })
  @IsOptional()
  is_shared?: boolean;
}

export class AddItemDto {
  @ApiProperty({ example: 'ingredient-uuid' })
  @IsString()
  ingredient_id: string;

  @ApiProperty({ example: 500 })
  @IsInt()
  @Min(0)
  quantity: number;

  @ApiProperty({ example: 'g' })
  @IsString()
  unit: string;

  @ApiProperty({ example: 'PRODUCE', required: false })
  @IsOptional()
  @IsString()
  store_section?: string;

  @ApiProperty({ example: 'Cà chua tươi', required: false })
  @IsOptional()
  @IsString()
  note?: string;

  @ApiProperty({ example: 'recipe-uuid', required: false })
  @IsOptional()
  @IsString()
  source_recipe_id?: string;
}

export class ShareListDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail()
  invited_email: string;

  @ApiProperty({ example: 'VIEWER', enum: ['VIEWER', 'EDITOR'], required: false })
  @IsOptional()
  @IsEnum(['VIEWER', 'EDITOR'])
  role?: 'VIEWER' | 'EDITOR';
}
