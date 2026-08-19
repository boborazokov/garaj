import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class DeleteAccountResult {
  @Field()
  success: boolean;
}
