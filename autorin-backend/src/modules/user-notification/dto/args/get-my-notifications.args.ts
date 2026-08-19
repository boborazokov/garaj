import { ArgsType, Field } from '@nestjs/graphql';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetMyNotificationsArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;
}
