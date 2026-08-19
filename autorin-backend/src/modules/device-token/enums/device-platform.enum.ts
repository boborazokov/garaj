import { registerEnumType } from '@nestjs/graphql';

/**
 * Mobile/web platform a given FCM registration token belongs to.
 * We keep this an enum (not a free-form string) so the push service
 * can apply platform-specific payload shaping (APNs vs Android).
 */
export enum DevicePlatformEnum {
  ANDROID = 'ANDROID',
  IOS = 'IOS',
  WEB = 'WEB',
}

registerEnumType(DevicePlatformEnum, {
  name: 'DevicePlatformEnum',
  description: 'Platform a FCM registration token was issued for.',
});
