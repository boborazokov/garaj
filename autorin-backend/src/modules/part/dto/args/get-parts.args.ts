import { ArgsType, Field } from '@nestjs/graphql';
import { PartFilterInput } from '../inputs';
import { PaginationInput } from 'src/shared/inputs';
import { SortOrderEnum } from 'src/shared/enums';

@ArgsType()
export class GetPartsArgs {
  @Field(() => PartFilterInput, { nullable: true })
  filter?: PartFilterInput;

  @Field({ nullable: true })
  search?: string;

  @Field()
  pagination: PaginationInput;

  @Field(() => SortOrderEnum, { nullable: true })
  sort?: SortOrderEnum;

  /**
   * Optional viewer region. If provided and `sort` is RECOMMENDED, promoted
   * items in this region float above promoted items elsewhere.
   */
  @Field({ nullable: true })
  viewerRegion?: string;
}
