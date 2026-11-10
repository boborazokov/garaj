import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PushModule } from 'src/services/push';
import { WalletModel, WalletTransactionModel } from '../model';
import { WalletResolver } from '../resolver';
import { WalletService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([WalletModel, WalletTransactionModel]),
    PushModule,
  ],
  providers: [WalletResolver, WalletService],
  exports: [WalletService],
})
export class WalletModule {}
