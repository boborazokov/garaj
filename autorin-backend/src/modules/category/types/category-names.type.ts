import { Field, InputType, ObjectType } from '@nestjs/graphql';
import { Prop, Schema } from '@nestjs/mongoose';

@ObjectType()
@Schema({ _id: false })
export class CategoryNames {
  @Field()
  @Prop({ trim: true, default: '' })
  en: string;

  @Field()
  @Prop({ trim: true, default: '' })
  ru: string;

  @Field()
  @Prop({ trim: true, default: '' })
  uz: string;
}

@InputType()
export class CategoryNamesInput {
  @Field()
  en: string;

  @Field()
  ru: string;

  @Field()
  uz: string;
}
