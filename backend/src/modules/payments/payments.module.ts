import { Module } from '@nestjs/common';
import { PaymentsController } from './payments.controller';
import { VNPayService } from './vnpay.service';
import { DatabaseModule } from '../../database/database.module';
import { SubscriptionsService } from '../subscriptions/subscriptions.service';

@Module({
  imports: [DatabaseModule],
  controllers: [PaymentsController],
  providers: [VNPayService, SubscriptionsService],
  exports: [VNPayService],
})
export class PaymentsModule {}

