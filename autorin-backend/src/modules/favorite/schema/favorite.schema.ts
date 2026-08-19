import { Field, ObjectType } from '@nestjs/graphql';
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { COLLECTIONS } from 'src/constants';

@Schema()
@ObjectType()
export class Favorite {
  @Field(() => ObjectIdScalar)
  @Prop({ type: Types.ObjectId, ref: COLLECTIONS.USERS })
  userId: Types.ObjectId;

  @Field(() => [ObjectIdScalar], { nullable: true })
  @Prop({
    type: [{ type: Types.ObjectId, ref: COLLECTIONS.PARTS }],
    default: [],
  })
  partsIds: Types.ObjectId[];

  @Field(() => [ObjectIdScalar], { nullable: true })
  @Prop({
    type: [{ type: Types.ObjectId, ref: COLLECTIONS.SERVICES }],
    default: [],
  })
  servicesIds: Types.ObjectId[];
}

export const FavoriteSchema = SchemaFactory.createForClass(Favorite);
