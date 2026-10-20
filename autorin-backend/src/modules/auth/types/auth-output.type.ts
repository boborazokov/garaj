import { Field, Int, ObjectType } from '@nestjs/graphql';
import { User } from 'src/modules/user/schema';

@ObjectType()
export class AuthOutput {
  /** Access token. Kept for clients that still read `token`. */
  @Field()
  token: string;

  @Field()
  accessToken: string;

  @Field({ nullable: true })
  refreshToken?: string;

  @Field({ nullable: true })
  sessionId?: string;

  @Field(() => Int, { nullable: true })
  tokenVersion?: number;

  @Field()
  user: User;
}
