import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class ReplyWorkshopReviewInput {
  @Field()
  reviewId: string;

  @Field()
  text: string;
}
