import { ArgsType, Field } from '@nestjs/graphql';
import { PaginationInput } from 'src/shared/inputs';
import { SortOrderEnum } from 'src/shared/enums';
import { OrderFilterInput } from '../inputs';

@ArgsType()
export class GetOrdersArgs {
  @Field(() => OrderFilterInput, { nullable: true })
  filter?: OrderFilterInput;

  @Field({ nullable: true })
  search?: string;

  @Field()
  pagination: PaginationInput;

  @Field(() => SortOrderEnum, { nullable: true })
  sort?: SortOrderEnum;

  @Field({ nullable: true })
  viewerRegion?: string;
}
