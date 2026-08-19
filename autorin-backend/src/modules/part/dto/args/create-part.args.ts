import { ArgsType, Field } from '@nestjs/graphql';
import { PartInput } from '../inputs';
import { DeepValidate } from 'src/common';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';

@ArgsType()
export class CreatePartArgs {
  @Field()
  @DeepValidate()
  data: PartInput;

  @Field(() => [GraphQLUpload])
  images: Promise<FileUpload>[];
}
