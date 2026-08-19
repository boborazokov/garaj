import { ArgsType, Field } from '@nestjs/graphql';
import { IsOptional } from 'class-validator';
import { PaginationInput } from 'src/shared/inputs';

@ArgsType()
export class GetConversationsArgs {
  @Field({ nullable: true })
  @IsOptional()
  pagination?: PaginationInput;
}
