import { ArgsType, Field } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { Types } from 'mongoose';

@ArgsType()
export class DeleteCategoryArgs {
  @Field(() => ObjectIdScalar)
  categoryId: Types.ObjectId;
}
