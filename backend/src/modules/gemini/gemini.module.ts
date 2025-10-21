import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { GeminiService } from './gemini.service';
import { GeminiController } from './gemini.controller';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [ConfigModule, DatabaseModule],
  controllers: [GeminiController],
  providers: [GeminiService],
  exports: [GeminiService],
})
export class GeminiModule {}
