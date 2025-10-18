import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class AddCommentDto {
  @ApiProperty({ example: 'Món này rất ngon!' })
  @IsString()
  @IsNotEmpty()
  content: string;
}

export class UpdateCommentDto {
  @ApiProperty({ example: 'Món này rất ngon và dễ làm!' })
  @IsString()
  @IsNotEmpty()
  content: string;
}

export class ReportCommentDto {
  @ApiProperty({ example: 'Nội dung không phù hợp' })
  @IsString()
  @IsNotEmpty()
  reason: string;
}
