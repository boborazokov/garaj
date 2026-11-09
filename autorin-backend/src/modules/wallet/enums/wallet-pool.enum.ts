import { registerEnumType } from '@nestjs/graphql';

export enum WalletPoolEnum {
  MAIN = 'MAIN',
  BONUS = 'BONUS',
  SPLIT = 'SPLIT',
}

registerEnumType(WalletPoolEnum, {
  name: 'WalletPoolEnum',
});
