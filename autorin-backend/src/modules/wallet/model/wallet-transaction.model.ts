import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { WalletTransaction } from '../schema';

const schema = SchemaFactory.createForClass(WalletTransaction);
schema.index({ user: 1, createdAt: -1 });
schema.index(
  { referenceType: 1, referenceId: 1, type: 1 },
  {
    unique: true,
    partialFilterExpression: {
      referenceId: { $type: 'objectId' },
      status: 'COMPLETED',
    },
  },
);

export const WalletTransactionModel: ModelDefinition = {
  name: COLLECTIONS.WALLET_TRANSACTIONS,
  schema,
};
