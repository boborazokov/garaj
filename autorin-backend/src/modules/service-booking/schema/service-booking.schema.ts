import { Field, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { User } from 'src/modules/user/schema';
import { CurrencyEnum } from 'src/shared/enums';
import { ServiceBookingPaymentStatusEnum } from '../enums/service-booking-payment-status.enum';
import { ServiceBookingStatusEnum } from '../enums/service-booking-status.enum';

@ObjectType()
@Schema({ timestamps: true })
export class ServiceBooking {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => AutoService)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.SERVICES, required: true, index: true })
  service: AutoService | Types.ObjectId;

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true, index: true })
  user: User | Types.ObjectId;

  @Field()
  @Prop({ required: true })
  scheduledAt: Date;

  @Field({ nullable: true })
  @Prop({ default: '' })
  notes?: string;

  @Field(() => ServiceBookingStatusEnum)
  @Prop({
    type: String,
    enum: Object.values(ServiceBookingStatusEnum),
    default: ServiceBookingStatusEnum.PENDING,
    index: true,
  })
  status: ServiceBookingStatusEnum;

  /** Platform fee charged to the payer (provider not credited in v1). */
  @Field(() => Int)
  @Prop({ required: true, min: 0, default: 0 })
  paidAmount: number;

  @Field(() => CurrencyEnum)
  @Prop({
    type: String,
    enum: Object.values(CurrencyEnum),
    default: CurrencyEnum.UZS,
  })
  currency: CurrencyEnum;

  @Field(() => ServiceBookingPaymentStatusEnum)
  @Prop({
    type: String,
    enum: Object.values(ServiceBookingPaymentStatusEnum),
    default: ServiceBookingPaymentStatusEnum.UNPAID,
    index: true,
  })
  paymentStatus: ServiceBookingPaymentStatusEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  @Prop({ type: Types.ObjectId, default: null })
  walletTransactionId?: Types.ObjectId | null;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
