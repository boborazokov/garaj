import { Field, InputType } from '@nestjs/graphql';
import { IsPhoneNumber, MinLength } from 'class-validator';
import { PASSWORD_MIN_LENGTH } from 'src/constants';

@InputType()
export class SignUpInput {
  @Field()
  name: string;

  @Field()
  @IsPhoneNumber('UZ')
  phone: string;

  @Field()
  @MinLength(PASSWORD_MIN_LENGTH)
  password: string;
}
