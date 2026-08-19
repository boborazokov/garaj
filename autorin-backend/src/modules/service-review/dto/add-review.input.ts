import { Field, Float, InputType } from '@nestjs/graphql';

@InputType()
export class AddReviewInput {
  @Field()
  serviceId: string;

  @Field(() => Float)
  rating: number;

  @Field({ nullable: true })
  text?: string;
}
