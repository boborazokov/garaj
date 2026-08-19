import { ArgsType, Field } from '@nestjs/graphql';
import { WorkshopInput } from '../inputs';
import { DeepValidate } from 'src/common';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';

@ArgsType()
export class CreateWorkshopArgs {
  @Field()
  @DeepValidate()
  data: WorkshopInput;

  @Field(() => [GraphQLUpload], { nullable: true })
  gallery?: Promise<FileUpload>[];

  @Field(() => GraphQLUpload, { nullable: true })
  coverImage?: Promise<FileUpload>;

  @Field(() => GraphQLUpload, { nullable: true })
  logo?: Promise<FileUpload>;
}
