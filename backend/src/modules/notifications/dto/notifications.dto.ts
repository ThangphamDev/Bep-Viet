import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, Min } from 'class-validator';

export class NotificationResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  type: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  body: string;

  @ApiProperty({ required: false })
  payload?: any;

  @ApiProperty()
  delivered_at: Date;

  @ApiProperty({ required: false })
  read_at?: Date;

  @ApiProperty()
  is_read: boolean;
}

export class GetNotificationsQueryDto {
  @ApiProperty({ required: false, default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  limit?: number;

  @ApiProperty({ required: false, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  offset?: number;

  @ApiProperty({ required: false, description: 'Filter by notification type' })
  @IsOptional()
  @IsString()
  type?: string;

  @ApiProperty({ required: false, description: 'Filter by read status: true, false, or all' })
  @IsOptional()
  @IsString()
  read?: string; // 'true', 'false', or 'all'
}

export class UnreadCountResponseDto {
  @ApiProperty()
  unreadCount: number;
}

export class CreateNotificationDto {
  @ApiProperty()
  @IsString()
  userId: string;

  @ApiProperty()
  @IsString()
  type: string;

  @ApiProperty()
  @IsString()
  title: string;

  @ApiProperty()
  @IsString()
  body: string;

  @ApiProperty({ required: false })
  @IsOptional()
  payload?: any;
}

