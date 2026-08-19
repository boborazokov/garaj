import { Field, ObjectType } from '@nestjs/graphql';
import { User } from 'src/modules/user/schema';

@ObjectType()
export class AuthOutput {
  @Field()
  token: string;

  @Field()
  user: User;
}
