import { ArgsType, Field } from '@nestjs/graphql';
import { PartUpdateInput } from '../inputs';
import { DeepValidate } from 'src/common';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';
import { GetPartByIdArgs } from './get-part-by-id.args';

@ArgsType()
export class UpdatePartByIdArgs extends GetPartByIdArgs {
  @Field()
  @DeepValidate()
  data: PartUpdateInput;

  @Field(() => [GraphQLUpload], { nullable: true })
  images?: Promise<FileUpload>[];
}
