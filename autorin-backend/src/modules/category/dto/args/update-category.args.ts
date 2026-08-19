import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';
import { CategoryInput } from '../inputs';
import { DeepValidate } from 'src/common';

@ArgsType()
export class UpdateCategoryArgs {
  @Field(() => ObjectIdScalar)
  categoryId: Types.ObjectId;

  @Field()
  @DeepValidate()
  data: CategoryInput;
}
