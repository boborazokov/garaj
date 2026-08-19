import { ArgsType, Field } from '@nestjs/graphql';
import { GraphQLUpload, FileUpload } from 'graphql-upload-ts';
import { PaginationInput } from 'src/shared/inputs';
import { ServiceFilterInput, ServiceInput } from '../inputs/service.input';

@ArgsType()
export class CreateServiceArgs {
  @Field(() => ServiceInput)
  data: ServiceInput;

  @Field(() => [GraphQLUpload], { nullable: true })
  images?: Promise<FileUpload>[];
}

@ArgsType()
export class GetServiceByIdArgs {
  @Field()
  serviceId: string;
}

@ArgsType()
export class GetServicesArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field(() => ServiceFilterInput, { nullable: true })
  filter?: ServiceFilterInput;

  @Field({ nullable: true })
  search?: string;
}
