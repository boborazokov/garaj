import { ArgsType, Field, Int } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { PaginationInput } from 'src/shared/inputs';
import { UserRoleEnum } from 'src/modules/user/enums';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { Types } from 'mongoose';
import { FileUpload, GraphQLUpload } from 'graphql-upload-ts';

@ArgsType()
export class SetProductModerationArgs {
  @Field()
  enabled: boolean;
}

@ArgsType()
export class SetContactInfoArgs {
  @Field()
  supportEmail: string;

  @Field()
  supportPhone: string;
}

@ArgsType()
export class SetUserRoleArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field(() => UserRoleEnum)
  role: UserRoleEnum;
}

@ArgsType()
export class AdminSetUserImageArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field(() => GraphQLUpload)
  image: Promise<FileUpload>;
}

@ArgsType()
export class AdminSetUserVerifiedArgs {
  @Field(() => ObjectIdScalar)
  userId: Types.ObjectId;

  @Field()
  verified: boolean;
}

@ArgsType()
export class ModeratePartArgs {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;

  @Field(() => String, { nullable: true })
  note?: string;
}

@ArgsType()
export class AdminListUsersArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field({ nullable: true })
  search?: string;
}

@ArgsType()
export class AdminDailyReportArgs {
  @Field(() => Int, { nullable: true, defaultValue: 14 })
  days?: number;
}

@ArgsType()
export class AdminListPartsArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field({ nullable: true })
  search?: string;

  @Field(() => CategoryTypeEnum, { nullable: true })
  categoryType?: CategoryTypeEnum;
}

@ArgsType()
export class AdminListOrdersArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field({ nullable: true })
  search?: string;
}
