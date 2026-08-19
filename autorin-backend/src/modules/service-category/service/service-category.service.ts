import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { ServiceCategory } from '../schema/service-category.schema';

const DEFAULT_CATEGORIES = [
  { slug: 'repair', name: 'Repair & maintenance', iconUrl: '' },
  { slug: 'tire', name: 'Tires & wheels', iconUrl: '' },
  { slug: 'body', name: 'Body & paint', iconUrl: '' },
  { slug: 'electric', name: 'Electrics & diagnostics', iconUrl: '' },
  { slug: 'detailing', name: 'Detailing & wash', iconUrl: '' },
  { slug: 'towing', name: 'Towing & emergency', iconUrl: '' },
];

@Injectable()
export class ServiceCategoryService implements OnModuleInit {
  constructor(
    @InjectModel(COLLECTIONS.SERVICE_CATEGORIES)
    private readonly categoryModel: Model<ServiceCategory>,
  ) {}

  async onModuleInit() {
    for (const cat of DEFAULT_CATEGORIES) {
      await this.categoryModel.updateOne(
        { slug: cat.slug },
        { $setOnInsert: cat },
        { upsert: true },
      );
    }
  }

  list() {
    return this.categoryModel.find().sort({ name: 1 }).lean();
  }
}
