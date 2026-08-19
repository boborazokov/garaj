import { getModelToken } from '@nestjs/mongoose';
import { PaginateModel } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { app } from 'src/main';
import { Advertisement } from 'src/modules/advertisement/schema';
import { Category } from 'src/modules/category/schema';
import { User } from 'src/modules/user/schema';

export const userModel = app.get<PaginateModel<User>>(
  getModelToken(COLLECTIONS.USERS),
);
export const categoryModel = app.get<PaginateModel<Category>>(
  getModelToken(COLLECTIONS.CATEGORIES),
);
export const advertisementModel = app.get<PaginateModel<Advertisement>>(
  getModelToken(COLLECTIONS.ADVERTISEMENTS),
);
