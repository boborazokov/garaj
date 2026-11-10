import { registerEnumType } from '@nestjs/graphql';

export enum WalletReferenceTypeEnum {
  ADMIN = 'ADMIN',
  TOPUP = 'TOPUP',
  PROMOTION_PAYMENT = 'PROMOTION_PAYMENT',
  SERVICE_BOOKING = 'SERVICE_BOOKING',
  ADVERTISEMENT = 'ADVERTISEMENT',
  WITHDRAW = 'WITHDRAW',
}

registerEnumType(WalletReferenceTypeEnum, {
  name: 'WalletReferenceTypeEnum',
});
