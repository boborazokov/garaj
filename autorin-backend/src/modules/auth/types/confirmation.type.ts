import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class ConfirmationOutput {
  @Field()
  token: string;
}
