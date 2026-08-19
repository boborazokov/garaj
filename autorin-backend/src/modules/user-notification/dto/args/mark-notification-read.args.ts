import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';

@ArgsType()
export class MarkNotificationReadArgs {
  @Field(() => ObjectIdScalar)
  notificationId: Types.ObjectId;
}
