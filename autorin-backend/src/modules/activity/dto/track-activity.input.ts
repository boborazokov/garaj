import { ArgsType, Field } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { ActivityTypeEnum } from '../enums';

@ArgsType()
export class TrackActivityArgs {
  @Field(() => ActivityTypeEnum)
  type: ActivityTypeEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  entityId?: Types.ObjectId;

  @Field({ nullable: true })
  metadata?: string;
}
