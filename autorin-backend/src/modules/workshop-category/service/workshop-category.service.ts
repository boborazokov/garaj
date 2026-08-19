import { Injectable, OnModuleInit } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import {
  pickCategoryName,
  resolveCategoryNamesFromDoc,
} from 'src/modules/category/utils/category-names.util';
import { WorkshopCategory } from '../schema/workshop-category.schema';
import {
  loadWorkshopCategoriesSeed,
  workshopSeedToDocs,
} from '../seed/seed-workshop-categories';

@Injectable()
export class WorkshopCategoryService implements OnModuleInit {
  constructor(
    @InjectModel(COLLECTIONS.WORKSHOP_CATEGORIES)
    private readonly categoryModel: Model<WorkshopCategory>,
  ) {}

  async onModuleInit() {
    await this.seedWorkshopCategories();
  }

  async seedWorkshopCategories(): Promise<number> {
    const rows = loadWorkshopCategoriesSeed();
    const docs = workshopSeedToDocs(rows);
    for (const doc of docs) {
      await this.categoryModel.updateOne(
        { slug: doc.slug },
        {
          $set: doc,
          $unset: { name: '', iconUrl: '' },
        },
        { upsert: true },
      );
    }
    return docs.length;
  }

  async list(locale?: string | null) {
    const rows = await this.categoryModel.find().lean().exec();
    const mapped = rows.map((row) => {
      const names = resolveCategoryNamesFromDoc(row);
      return {
        ...row,
        names,
        name: pickCategoryName(names, locale),
      };
    });
    mapped.sort((a, b) => {
      const ap = a.popular ? 1 : 0;
      const bp = b.popular ? 1 : 0;
      if (ap !== bp) return bp - ap;
      return (a.names?.ru ?? '').localeCompare(b.names?.ru ?? '', 'ru');
    });
    return mapped;
  }

  findByIds(ids: string[]) {
    return this.categoryModel
      .find({ _id: { $in: ids } })
      .sort({ popular: -1, 'names.ru': 1 })
      .lean();
  }
}
