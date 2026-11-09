import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { CurrencyEnum } from 'src/shared/enums';

@ObjectType()
@Schema({ timestamps: true, collection: COLLECTIONS.WALLETS })
export class Wallet {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => ObjectIdScalar)
  @Prop({
    type: Types.ObjectId,
    ref: COLLECTIONS.USERS,
    required: true,
    unique: true,
    index: true,
  })
  user: Types.ObjectId;

  @Field(() => Int)
  @Prop({ required: true, min: 0, default: 0 })
  mainBalance: number;

  @Field(() => Int)
  @Prop({ required: true, min: 0, default: 0 })
  bonusBalance: number;

  @Field(() => Int)
  availableTotal: number;

  @Field(() => CurrencyEnum)
  @Prop({
    type: String,
    enum: Object.values(CurrencyEnum),
    default: CurrencyEnum.UZS,
  })
  currency: CurrencyEnum;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
