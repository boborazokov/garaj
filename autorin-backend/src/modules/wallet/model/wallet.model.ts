import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { Wallet } from '../schema';

const schema = SchemaFactory.createForClass(Wallet);

export const WalletModel: ModelDefinition = {
  name: COLLECTIONS.WALLETS,
  schema,
};
