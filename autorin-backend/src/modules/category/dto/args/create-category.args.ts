import { ArgsType, Field } from '@nestjs/graphql';
import { CategoryInput } from '../inputs';
import { DeepValidate } from 'src/common';

@ArgsType()
export class CreateCategoryArgs {
  @Field()
  @DeepValidate()
  data: CategoryInput;
}
