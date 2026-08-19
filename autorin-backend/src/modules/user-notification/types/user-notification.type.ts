import { Field, ObjectType } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';

@ObjectType()
export class UserNotificationType {
  @Field(() => ObjectIdScalar)
  _id: Types.ObjectId;

  @Field()
  type: string;

  @Field()
  title: string;

  @Field()
  body: string;

  @Field({ nullable: true })
  deepLink?: string;

  @Field()
  isRead: boolean;

  @Field()
  createdAt: Date;
}
