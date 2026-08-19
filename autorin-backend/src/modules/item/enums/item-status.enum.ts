import { registerEnumType } from '@nestjs/graphql';

export enum ItemStatusEnum {
  ACTIVE = 'ACTIVE',
  ARCHIVED = 'ARCHIVED',
  /** Awaiting moderator approval when product moderation is enabled. */
  PENDING_MODERATION = 'PENDING_MODERATION',
  /** Rejected by moderator; visible only to seller. */
  REJECTED = 'REJECTED',
}

registerEnumType(ItemStatusEnum, {
  name: 'ItemStatusEnum',
});
