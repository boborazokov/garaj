import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { AutoService } from 'src/modules/service/schema/service.schema';
import { User } from 'src/modules/user/schema';
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

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
