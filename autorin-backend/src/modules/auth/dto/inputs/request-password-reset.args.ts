import { ArgsType, Field } from '@nestjs/graphql';
import { IsPhoneNumber } from 'class-validator';

@ArgsType()
export class RequestPasswordResetArgs {
  @Field()
  @IsPhoneNumber('UZ')
  phone: string;
}
