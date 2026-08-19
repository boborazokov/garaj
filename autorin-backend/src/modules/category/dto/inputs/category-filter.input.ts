import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryTypeEnum } from '../../enums';

@InputType()
export class CategoryFilterInput {
  @Field(() => CategoryTypeEnum, { nullable: true })
  type?: CategoryTypeEnum;

  /**
   * Filter by parent. Pass `null` (omit) to fetch root nodes for the
   * provided `type`, or pass an id to fetch direct children.
   */
  @Field(() => ObjectIdScalar, { nullable: true })
  parentId?: Types.ObjectId;

  @Field({ nullable: true })
  search?: string;
}
