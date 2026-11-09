import { ArgsType, Field, Int } from '@nestjs/graphql';
import { ObjectIdScalar } from 'src/common';
import { PaginationInput } from 'src/shared/inputs';
import { UserRoleEnum } from 'src/modules/user/enums';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { AdminPartsSortEnum } from '../../enums/admin-parts-sort.enum';
import { AdminWorkshopsSortEnum } from '../../enums/admin-workshops-sort.enum';
import { AdminOrdersSortEnum } from '../../enums/admin-orders-sort.enum';
import { OrderStatusEnum } from 'src/modules/order/enums';
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

  @Field(() => ItemStatusEnum, { nullable: true })
  status?: ItemStatusEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  category?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  sellerId?: Types.ObjectId;

  @Field({ nullable: true })
  minPrice?: number;

  @Field({ nullable: true })
  maxPrice?: number;

  @Field(() => Date, { nullable: true })
  createdFrom?: Date;

  @Field(() => Date, { nullable: true })
  createdTo?: Date;

  @Field({ nullable: true })
  isPromoted?: boolean;

  @Field(() => AdminPartsSortEnum, { nullable: true })
  sort?: AdminPartsSortEnum;
}

@ArgsType()
export class AdminSetPartRecommendedArgs {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;

  @Field()
  recommended: boolean;
}

@ArgsType()
export class AdminSetOrderRecommendedArgs {
  @Field(() => ObjectIdScalar)
  orderId: Types.ObjectId;

  @Field()
  recommended: boolean;
}

@ArgsType()
export class AdminSetPartViewsCountArgs {
  @Field(() => ObjectIdScalar)
  partId: Types.ObjectId;

  @Field(() => Int)
  viewsCount: number;
}

@ArgsType()
export class AdminListOrdersArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field({ nullable: true })
  search?: string;

  @Field(() => OrderStatusEnum, { nullable: true })
  status?: OrderStatusEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  partCategoryId?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  authorId?: Types.ObjectId;

  @Field(() => Date, { nullable: true })
  createdFrom?: Date;

  @Field(() => Date, { nullable: true })
  createdTo?: Date;

  @Field({ nullable: true })
  isPromoted?: boolean;

  @Field(() => AdminOrdersSortEnum, { nullable: true })
  sort?: AdminOrdersSortEnum;
}

@ArgsType()
export class AdminListWorkshopsArgs {
  @Field(() => PaginationInput, { nullable: true })
  pagination?: PaginationInput;

  @Field({ nullable: true })
  search?: string;

  @Field(() => ItemStatusEnum, { nullable: true })
  status?: ItemStatusEnum;

  @Field(() => ObjectIdScalar, { nullable: true })
  categoryId?: Types.ObjectId;

  @Field(() => ObjectIdScalar, { nullable: true })
  ownerId?: Types.ObjectId;

  @Field(() => Date, { nullable: true })
  createdFrom?: Date;

  @Field(() => Date, { nullable: true })
  createdTo?: Date;

  @Field({ nullable: true })
  isPromoted?: boolean;

  @Field(() => AdminWorkshopsSortEnum, { nullable: true })
  sort?: AdminWorkshopsSortEnum;
}

@ArgsType()
export class AdminSetWorkshopRecommendedArgs {
  @Field(() => ObjectIdScalar)
  workshopId: Types.ObjectId;

  @Field()
  recommended: boolean;
}
