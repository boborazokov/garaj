import { ArgsType, Field } from '@nestjs/graphql';
import { ViewsTargetInput } from '../inputs';

@ArgsType()
export class GetTargetViewsCountArgs {
  @Field(() => ViewsTargetInput)
  target: ViewsTargetInput;
}
