import { ArgsType, Field } from '@nestjs/graphql';
import { WorkshopUpdateInput } from '../inputs';
import { DeepValidate } from 'src/common';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';
import { GetWorkshopByIdArgs } from './get-workshop-by-id.args';

@ArgsType()
export class UpdateWorkshopByIdArgs extends GetWorkshopByIdArgs {
  @Field()
  @DeepValidate()
  data: WorkshopUpdateInput;

  @Field(() => [GraphQLUpload], { nullable: true })
  images?: Promise<FileUpload>[];
}
