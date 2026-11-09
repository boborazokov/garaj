import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { WalletModel, WalletTransactionModel } from '../model';
import { WalletResolver } from '../resolver';
import { WalletService } from '../service';

@Module({
  imports: [
    MongooseModule.forFeature([WalletModel, WalletTransactionModel]),
  ],
  providers: [WalletResolver, WalletService],
  exports: [WalletService],
})
export class WalletModule {}
