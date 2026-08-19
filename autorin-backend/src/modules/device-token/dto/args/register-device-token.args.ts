import { ArgsType, Field } from '@nestjs/graphql';
import { DeepValidate } from 'src/common';
import { RegisterDeviceTokenInput } from '../inputs';

@ArgsType()
export class RegisterDeviceTokenArgs {
  @Field()
  @DeepValidate()
  data: RegisterDeviceTokenInput;
}
