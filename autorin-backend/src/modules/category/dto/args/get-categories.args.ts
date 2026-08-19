import { ArgsType, Field } from '@nestjs/graphql';
import { CategoryFilterInput } from '../inputs';

@ArgsType()
export class GetCategoriesArgs {
  @Field(() => CategoryFilterInput, { nullable: true })
  filter?: CategoryFilterInput;
}
