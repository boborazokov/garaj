import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';
import { Workshop } from 'src/modules/workshop/schema/workshop.schema';
import { User } from 'src/modules/user/schema';
import { WorkshopBookingStatusEnum } from '../enums/workshop-booking-status.enum';

@ObjectType()
@Schema({ timestamps: true })
export class WorkshopBooking {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field(() => Workshop)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.WORKSHOPS, required: true, index: true })
  workshop: Workshop | Types.ObjectId;

  @Field(() => User)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS, required: true, index: true })
  user: User | Types.ObjectId;

  @Field()
  @Prop({ required: true })
  scheduledAt: Date;

  @Field({ nullable: true })
  @Prop({ default: '' })
  notes?: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  serviceLabel?: string;

  @Field(() => WorkshopBookingStatusEnum)
  @Prop({
    type: String,
    enum: Object.values(WorkshopBookingStatusEnum),
    default: WorkshopBookingStatusEnum.PENDING,
    index: true,
  })
  status: WorkshopBookingStatusEnum;

  @Field()
  createdAt: Date;

  @Field({ nullable: true })
  updatedAt?: Date;
}
