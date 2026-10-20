import { ArgsType, Field } from '@nestjs/graphql';
import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, Matches, MinLength } from 'class-validator';
import { OTP_CODE_LENGTH, PASSWORD_MIN_LENGTH } from 'src/constants';

@ArgsType()
export class ResetPasswordArgs {
  @Field()
  @IsString()
  @IsNotEmpty()
  token: string;

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

  @Field()
  @MinLength(PASSWORD_MIN_LENGTH)
  password: string;
}
