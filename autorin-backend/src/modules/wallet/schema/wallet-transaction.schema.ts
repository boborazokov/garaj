import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { CurrencyEnum } from 'src/shared/enums';
import {
  WalletPoolEnum,
  WalletReferenceTypeEnum,
  WalletTransactionStatusEnum,
  WalletTransactionTypeEnum,
} from '../enums';

@ObjectType()
@Schema({ timestamps: true, collection: COLLECTIONS.WALLET_TRANSACTIONS })
export class WalletTransaction {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.WALLETS,
    required: true,
    index: true,
  })
  wallet: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    index: true,
  })
  user: Types.ObjectId;

  @Field(() => WalletTransactionTypeEnum)
  @Prop({
    type: String,
    enum: Object.values(WalletTransactionTypeEnum),
    required: true,
    index: true,
  })
  type: WalletTransactionTypeEnum;

  @Field(() => WalletPoolEnum)
  @Prop({
    type: String,
    enum: Object.values(WalletPoolEnum),
    required: true,
  })
  pool: WalletPoolEnum;

  /** Positive = credit, negative = debit. Always whole UZS. */
  @Field(() => Int)
  @Prop({ required: true })
  amount: number;

  @Field(() => Int)
  @Prop({ required: true, min: 0 })
  balanceAfterMain: number;

  @Field(() => Int)
  @Prop({ required: true, min: 0 })
  balanceAfterBonus: number;

  @Field(() => WalletTransactionStatusEnum)
  @Prop({
    type: String,
    enum: Object.values(WalletTransactionStatusEnum),
    default: WalletTransactionStatusEnum.COMPLETED,
    index: true,
  })
  status: WalletTransactionStatusEnum;

  @Field(() => CurrencyEnum)
  @Prop({
    type: String,
    enum: Object.values(CurrencyEnum),
    default: CurrencyEnum.UZS,
  })
  currency: CurrencyEnum;

  @Field(() => WalletReferenceTypeEnum, { nullable: true })
  @Prop({
    type: String,
    enum: Object.values(WalletReferenceTypeEnum),
    default: null,
    index: true,
  })
  referenceType?: WalletReferenceTypeEnum | null;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, default: null, index: true })
  referenceId?: Types.ObjectId | null;

  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null })
  note?: string | null;

  /** Opaque JSON string for provider / audit extras. */
  @Field(() => String, { nullable: true })
  @Prop({ type: String, default: null })
  metaJson?: string | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
