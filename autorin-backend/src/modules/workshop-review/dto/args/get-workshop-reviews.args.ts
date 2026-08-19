import { ArgsType, Field } from '@nestjs/graphql';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetWorkshopReviewsArgs {
  @Field()
  workshopId: string;

  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;
}
