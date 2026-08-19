import { registerEnumType } from '@nestjs/graphql';

export enum CurrencyEnum {
  USD = 'USD',
  UZS = 'UZS',
}

registerEnumType(CurrencyEnum, {
  name: 'CurrencyEnum',
});
