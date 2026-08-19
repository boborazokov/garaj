import { Field, InputType } from '@nestjs/graphql';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import { CurrencyEnum } from 'src/shared/enums';

@InputType()
export class PartFilterInput {
  @Field(() => ObjectIdScalar, { nullable: true })
  seller?: Types.ObjectId;

  /** Direct part-category id (leaf). */
  @Field(() => ObjectIdScalar, { nullable: true })
  category?: Types.ObjectId;

  /** Filter by car brand. */
  @Field(() => ObjectIdScalar, { nullable: true })
  brand?: Types.ObjectId;

  /** Filter by car model. */
  @Field(() => ObjectIdScalar, { nullable: true })
  carModel?: Types.ObjectId;

  @Field({ nullable: true })
  isNegotiable?: boolean;

  @Field({ nullable: true })
  hasDelivery?: boolean;

  @Field({ nullable: true })
  isNew?: boolean;

  @Field({ nullable: true })
  minPrice?: number;

  @Field({ nullable: true })
  maxPrice?: number;

  @Field(() => CurrencyEnum, { nullable: true })
  currency?: CurrencyEnum;

  /** Region / city filter. */
  @Field({ nullable: true })
  region?: string;

  /** Limit to promoted items only. */
  @Field({ nullable: true })
  isPromoted?: boolean;

  /** Signed-in viewer's saved parts (requires JWT). */
  @Field({ nullable: true })
  onlyFavorites?: boolean;
}
