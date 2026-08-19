import { Field, ObjectType } from '@nestjs/graphql';

import { Types } from 'mongoose';

import { ObjectIdScalar } from 'src/common';

import { CategoryTypeEnum } from '../enums';

import { CategoryNames } from './category-names.type';



@ObjectType()

export class CategoryTreeNode {

  @Field(() => ObjectIdScalar)

  _id: Types.ObjectId;



  @Field()

  name: string;



  @Field(() => CategoryNames)

  names: CategoryNames;



  @Field({ nullable: true })

  iconUrl?: string;



  @Field(() => CategoryTypeEnum)

  type: CategoryTypeEnum;



  @Field(() => ObjectIdScalar, { nullable: true })

  parentId?: Types.ObjectId | null;



  @Field(() => [CategoryTreeNode])

  children: CategoryTreeNode[];

}

