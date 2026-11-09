import { Field, InputType, Int } from '@nestjs/graphql';

@InputType()
export class BookServiceInput {
  @Field()
  serviceId: string;

  @Field()
  scheduledAt: Date;

  @Field({ nullable: true })
  notes?: string;

  /** Optional override; defaults to platform booking fee. */
  @Field(() => Int, { nullable: true })
  amount?: number;
}
