import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';

@InputType()
export class WorkshopFilterInput {
  @Field(() => ObjectIdScalar, { nullable: true })
  owner?: Types.ObjectId;

  @Field({ nullable: true })
  isOpen?: boolean;

  @Field({ nullable: true })
  openNow?: boolean;

  @Field({ nullable: true })
  verified?: boolean;

  @Field({ nullable: true })
  fastResponse?: boolean;

  @Field(() => ObjectIdScalar, { nullable: true })
  categoryId?: Types.ObjectId;

  @Field({ nullable: true })
  city?: string;
}
