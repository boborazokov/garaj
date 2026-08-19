import { Field, Float, InputType, Int, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';

@ObjectType()
@Schema({ _id: false })
export class WorkshopDaySchedule {
  @Field(() => Int)
  @Prop({ required: true, min: 0, max: 6 })
  day: number;

  @Field()
  @Prop({ default: false })
  closed: boolean;

  @Field({ nullable: true })
  @Prop({ default: '09:00' })
  openTime?: string;

  @Field({ nullable: true })
  @Prop({ default: '18:00' })
  closeTime?: string;
}

@InputType()
export class WorkshopDayScheduleInput {
  @Field(() => Int)
  day: number;

  @Field()
  closed: boolean;

  @Field({ nullable: true })
  openTime?: string;

  @Field({ nullable: true })
  closeTime?: string;
}

@ObjectType()
@Schema({ _id: false })
export class WorkshopServicePrice {
  @Field()
  @Prop({ required: true })
  label: string;

  @Field({ nullable: true })
  @Prop({ default: '' })
  categorySlug?: string;

  @Field(() => Float, { nullable: true })
  @Prop({ type: Number, default: null })
  priceFrom?: number | null;

  @Field(() => Float, { nullable: true })
  @Prop({ type: Number, default: null })
  priceTo?: number | null;

  @Field({ nullable: true })
  @Prop({ default: 'UZS' })
  currency?: string;
}

@InputType()
export class WorkshopServicePriceInput {
  @Field()
  label: string;

  @Field({ nullable: true })
  categorySlug?: string;

  @Field(() => Float, { nullable: true })
  priceFrom?: number;

  @Field(() => Float, { nullable: true })
  priceTo?: number;

  @Field({ nullable: true })
  currency?: string;
}
