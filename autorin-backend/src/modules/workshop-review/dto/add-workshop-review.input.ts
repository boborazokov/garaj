import { Field, Float, InputType } from '@nestjs/graphql';

@InputType()
export class AddWorkshopReviewInput {
  @Field()
  workshopId: string;

  @Field(() => Float)
  rating: number;

  @Field({ nullable: true })
  text?: string;
}
