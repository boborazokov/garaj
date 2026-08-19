import { ArgsType, Field } from '@nestjs/graphql';
import { WorkshopFilterInput } from '../inputs';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetWorkshopsArgs {
  @Field(() => WorkshopFilterInput, { nullable: true })
  filter?: WorkshopFilterInput;

  @Field({ nullable: true })
  search?: string;

  @Field()
  pagination: PaginationInput;
}
