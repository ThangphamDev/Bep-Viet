import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsObject, IsEnum, IsInt, Min, Max, MinLength } from 'class-validator';

export class UserPreferencesDto {
  @ApiProperty({ example: 2, minimum: 1, required: false })
  @IsOptional()
  @IsInt()
  @Min(1)
  household_size?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  spicy_level?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  taste_spicy?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  taste_salty?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  taste_sweet?: number;

  @ApiProperty({ example: 2, minimum: 0, maximum: 5, required: false })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(5)
  taste_light?: number;
}

export class UpdateProfileDto {
  @ApiProperty({ example: 'Nguyễn Văn A', required: false })
  @IsOptional()
  @IsString()
  name?: string;

  @ApiProperty({ example: 'BAC', enum: ['BAC', 'TRUNG', 'NAM'], required: false })
  @IsOptional()
  @IsEnum(['BAC', 'TRUNG', 'NAM'])
  region?: 'BAC' | 'TRUNG' | 'NAM';

  @ApiProperty({ example: 'Hà Nội', required: false })
  @IsOptional()
  @IsString()
  subregion?: string;

  @ApiProperty({ type: UserPreferencesDto, required: false })
  @IsOptional()
  preferences?: UserPreferencesDto;
}

export class ChangePasswordDto {
  @ApiProperty({ example: 'currentPassword123' })
  @IsString()
  currentPassword: string;

  @ApiProperty({ example: 'newPassword123' })
  @IsString()
  @MinLength(8)
  newPassword: string;
}

export class UserProfileDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  email: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  role: string;

  @ApiProperty()
  region?: string;

  @ApiProperty()
  subregion?: string;

  @ApiProperty()
  created_at: Date;
}
