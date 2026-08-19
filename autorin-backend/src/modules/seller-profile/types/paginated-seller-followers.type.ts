import { Field, ObjectType } from '@nestjs/graphql';
import { PaginationResult } from 'src/shared/types';
import { SellerFollower } from './seller-follower.type';

@ObjectType()
export class PaginatedSellerFollowers extends PaginationResult {
  @Field(() => [SellerFollower])
  payload: SellerFollower[];
}
