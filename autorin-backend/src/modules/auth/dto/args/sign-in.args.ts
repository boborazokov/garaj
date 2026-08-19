import { ArgsType, Field } from '@nestjs/graphql';
import { SignInInput } from '../inputs';
import { DeepValidate } from 'src/common';

@ArgsType()
export class SignInArgs {
  @Field()
  @DeepValidate()
  data: SignInInput;
}
