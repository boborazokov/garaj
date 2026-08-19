import { Field, Float, InputType } from '@nestjs/graphql';

@InputType()
export class UpdateWorkshopReviewInput {
  @Field()
  reviewId: string;

  @Field(() => Float)
  rating: number;

  @Field({ nullable: true })
  text?: string;
}
