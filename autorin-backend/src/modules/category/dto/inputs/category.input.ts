import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CategoryTypeEnum } from '../../enums';
import { CategoryNamesInput } from '../../types/category-names.type';

@InputType()
export class CategoryInput {
  @Field(() => CategoryNamesInput)
  names: CategoryNamesInput;

  @Field(() => CategoryTypeEnum)
  type: CategoryTypeEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  parentId?: Types.ObjectId;

  @Field({ nullable: true })
  iconUrl?: string;

  @Field({ nullable: true })
  key?: string;

  @Field({ nullable: true })
  icon?: string;
}
