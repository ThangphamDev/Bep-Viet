import { Module } from '@nestjs/common';
import { AdvisoryController } from './advisory.controller';
import { AdvisoryService } from './advisory.service';
import { DatabaseModule } from '../../database/database.module';

@Module({
  imports: [DatabaseModule],
  controllers: [AdvisoryController],
  providers: [AdvisoryService],
  exports: [AdvisoryService],
})
export class AdvisoryModule {}
