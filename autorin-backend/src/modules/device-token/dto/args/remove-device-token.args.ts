import { ArgsType, Field } from '@nestjs/graphql';
import { MaxLength, MinLength } from 'class-validator';

@ArgsType()
export class RemoveDeviceTokenArgs {
  @Field()
  @MinLength(10)
  @MaxLength(4096)
  token: string;
}
