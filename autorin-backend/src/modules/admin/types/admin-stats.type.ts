import { Field, ObjectType } from '@nestjs/graphql';

@ObjectType()
export class AdminStats {
  @Field()
  usersCount: number;

  @Field()
  partsCount: number;

  @Field()
  activePartsCount: number;

  @Field()
  pendingModerationCount: number;

  @Field()
  ordersCount: number;
}
