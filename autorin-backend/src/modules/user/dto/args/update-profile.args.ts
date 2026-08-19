import { ArgsType, Field } from '@nestjs/graphql';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';
import { UserUpdateInput } from '../inputs';

@ArgsType()
export class UpdateProfileArgs {
  @Field(() => UserUpdateInput)
  data: UserUpdateInput;

  @Field(() => GraphQLUpload, { nullable: true })
  image?: Promise<FileUpload>;
}
