import { ArgsType, Field } from '@nestjs/graphql';
import { SignUpInput } from '../inputs';
import { DeepValidate } from 'src/common';

@ArgsType()
export class SignUpArgs {
  @Field()
  @DeepValidate()
  data: SignUpInput;
}
