import { ArgsType, Field } from '@nestjs/graphql';
import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, Matches } from 'class-validator';
import { OTP_CODE_LENGTH } from 'src/constants';

@ArgsType()
export class ConfirmSignUpArgs {
  /** JWT confirmation token returned by signUp. */
  @Field()
  @IsString()
  @IsNotEmpty()
  token: string;

  /** 5-digit OTP from SMS (leading zeros allowed). */
  @Field()
  @IsString()
  @Transform(({ value }) =>
    String(value ?? '')
      .trim()
      .replace(/\D/g, '')
      .padStart(OTP_CODE_LENGTH, '0')
      .slice(-OTP_CODE_LENGTH),
  )
  @Matches(/^\d{5}$/, { message: 'OTP must be exactly 5 digits' })
  code: string;
}
