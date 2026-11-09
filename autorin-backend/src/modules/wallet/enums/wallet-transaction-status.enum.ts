import { registerEnumType } from '@nestjs/graphql';

export enum WalletTransactionStatusEnum {
  PENDING = 'PENDING',
  COMPLETED = 'COMPLETED',
  FAILED = 'FAILED',
  CANCELLED = 'CANCELLED',
}

registerEnumType(WalletTransactionStatusEnum, {
  name: 'WalletTransactionStatusEnum',
});
