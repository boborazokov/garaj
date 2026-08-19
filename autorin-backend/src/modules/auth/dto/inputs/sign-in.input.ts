import { Field, InputType } from '@nestjs/graphql';
import { IsPhoneNumber, MinLength } from 'class-validator';
import { PASSWORD_MIN_LENGTH } from 'src/constants';

@InputType()
export class SignInInput {
  @Field()
  @IsPhoneNumber('UZ')
  phone: string;

  @Field()
  @MinLength(PASSWORD_MIN_LENGTH)
  password: string;
}
