import { Field, InputType } from '@nestjs/graphql';

@InputType()
export class BookWorkshopInput {
  @Field()
  workshopId: string;

  @Field()
  scheduledAt: Date;

  @Field({ nullable: true })
  notes?: string;

  @Field({ nullable: true })
  serviceLabel?: string;
}
