import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class ConfirmationOutput {
  @Field()
  token: string;

  /** Dev-only hint from signUp; omitted in production. Do not use for verification. */
  @Field({ nullable: true })
  correctCode?: number;
}
