import { ArgsType, Field } from '@nestjs/graphql';
import { IsOptional, IsString, MinLength } from 'class-validator';

@ArgsType()
export class RefreshSessionArgs {
  @Field()
  @IsString()
  @MinLength(20)
  refreshToken: string;

  @Field()
  @IsString()
  @MinLength(4)
  deviceId: string;
}

@ArgsType()
export class LogoutSessionArgs {
  @Field()
  @IsString()
  @MinLength(20)
  refreshToken: string;

  @Field({ nullable: true })
  @IsOptional()
  @IsString()
  sessionId?: string;
}
