import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class BookServiceInput {
  @Field()
  serviceId: string;

  @Field()
  scheduledAt: Date;

  @Field({ nullable: true })
  notes?: string;
}
