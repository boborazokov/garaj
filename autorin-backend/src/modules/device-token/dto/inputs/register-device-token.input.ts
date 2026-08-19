import { Field, InputType } from '@nestjs/graphql';
import { IsOptional, MaxLength, MinLength } from 'class-validator';
import { DevicePlatformEnum } from '../../enums';

@InputType()
export class RegisterDeviceTokenInput {
  /** FCM registration token returned by `FirebaseMessaging.instance.getToken()`. */
  @Field()
  @MinLength(10)
  @MaxLength(4096)
  token: string;

  @Field(() => DevicePlatformEnum)
  platform: DevicePlatformEnum;

  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(16)
  locale?: string;

  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(32)
  appVersion?: string;

  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(64)
  deviceModel?: string;
}
