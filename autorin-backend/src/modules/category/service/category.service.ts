import { BadRequestException, Injectable } from '@nestjs/common';

import { InjectModel } from '@nestjs/mongoose';

import { COLLECTIONS } from 'src/constants';

import { Category } from '../schema';

import { FilterQuery, Model, Types } from 'mongoose';

import { CreateCategoryArgs, GetCategoriesArgs } from '../dto';

import { CategoryInput } from '../dto/inputs';

import { CategoryTreeNode } from '../types';

import { CategoryTypeEnum } from '../enums';

import {

  normalizeCategoryNames,

  normalizeCategoryNamesInput,

  pickCategoryName,

  resolveCategoryNamesFromDoc,

} from '../utils/category-names.util';
import {
  loadPartsCategoriesSeed,
  partsSeedToCategoryDocs,
} from '../seed/seed-parts-categories';
import {
  exactNameRegex,
  loadVehicleCatalogSeed,
  slugModelKey,
} from '../seed/seed-vehicle-catalog';

function withNormalizedNames<T extends { names?: unknown; name?: unknown }>(

  row: T,

  locale?: string | null,

): T & { names: ReturnType<typeof normalizeCategoryNames>; name: string } {

  const names = resolveCategoryNamesFromDoc(row);

  return {

    ...row,

    names,

    name: pickCategoryName(names, locale),

  };

}



@Injectable()

export class CategoryService {

  constructor(

    @InjectModel(COLLECTIONS.CATEGORIES) private categoryModel: Model<Category>,

  ) {}



  async getCategories(

    { filter = {} }: GetCategoriesArgs,

    locale?: string | null,

  ): Promise<Category[]> {

    const query: FilterQuery<Category> = {};

    if (filter.type) query.type = filter.type;

    if (filter.parentId !== undefined) {

      query.parentId = filter.parentId

        ? new Types.ObjectId(filter.parentId)

        : null;

    }

    if (filter.search) {

      const rx = { $regex: filter.search, $options: 'i' };

      query.$or = [

        { 'names.en': rx },

        { 'names.ru': rx },

        { 'names.uz': rx },

        { name: rx },

      ];

    }



    const rows = await this.categoryModel

      .find(query)

      .sort({ 'names.ru': 1, name: 1 })

      .lean()

      .exec();

    return rows.map((row) => withNormalizedNames(row, locale)) as Category[];

  }



  async getCategoryTree(

    rootType: CategoryTypeEnum = CategoryTypeEnum.BRAND,

    locale?: string | null,

  ): Promise<CategoryTreeNode[]> {

    const all = await this.categoryModel.find().lean().exec();



    const byParent = new Map<string, CategoryTreeNode[]>();

    for (const c of all) {

      const names = resolveCategoryNamesFromDoc(c);

      const key = c.parentId ? c.parentId.toString() : 'ROOT';

      const node: CategoryTreeNode = {

        _id: c._id as Types.ObjectId,

        names,

        name: pickCategoryName(names, locale),

        iconUrl: c.iconUrl,

        type: c.type,

        parentId: c.parentId ?? null,

        children: [],

      };

      if (!byParent.has(key)) byParent.set(key, []);

      byParent.get(key)!.push(node);

    }



    const attachChildren = (node: CategoryTreeNode) => {

      const kids = byParent.get(node._id.toString()) ?? [];

      node.children = kids;

      kids.forEach(attachChildren);

    };



    const roots = (byParent.get('ROOT') ?? []).filter((n) => n.type === rootType);

    roots.forEach(attachChildren);



    return roots;

  }



  async createCategory({ data }: CreateCategoryArgs): Promise<Category> {

    this.validateCategoryHierarchy(data.type, data.parentId);

    const names = normalizeCategoryNamesInput(data.names);

    const created = await this.categoryModel.create({

      names,

      type: data.type,

      parentId: data.parentId ? new Types.ObjectId(data.parentId) : null,

      iconUrl: data.iconUrl ?? '',

      key: data.key?.trim() || undefined,

      icon: data.icon?.trim() ?? '',

    });

    return withNormalizedNames(created.toObject(), null) as Category;

  }



  async updateCategory(

    categoryId: Types.ObjectId,

    data: CategoryInput,

  ): Promise<Category> {

    this.validateCategoryHierarchy(data.type, data.parentId);

    const names = normalizeCategoryNamesInput(data.names);

    const updated = await this.categoryModel.findByIdAndUpdate(

      categoryId,

      {

        $set: {

          names,

          type: data.type,

          parentId: data.parentId ? new Types.ObjectId(data.parentId) : null,

          iconUrl: data.iconUrl ?? '',

          key: data.key?.trim() || undefined,

          icon: data.icon?.trim() ?? '',

        },

        $unset: { name: '' },

      },

      { new: true },

    );

    if (!updated) throw new BadRequestException('Category not found');

    return withNormalizedNames(updated.toObject(), null) as Category;

  }



  async deleteCategory(categoryId: Types.ObjectId): Promise<boolean> {

    const found = await this.categoryModel.findById(categoryId);

    if (!found) throw new BadRequestException('Category not found');



    const childCount = await this.categoryModel.countDocuments({

      parentId: categoryId,

    });

    if (childCount > 0) {

      throw new BadRequestException(

        'Cannot delete category with child categories',

      );

    }



    await this.categoryModel.deleteOne({ _id: categoryId });

    return true;

  }



  private validateCategoryHierarchy(

    type: CategoryTypeEnum,

    parentId?: Types.ObjectId | null,

  ) {

    if (type === CategoryTypeEnum.BRAND && parentId) {

      throw new BadRequestException('BRAND cannot have a parent');

    }

    if (type === CategoryTypeEnum.MODEL && !parentId) {

      throw new BadRequestException('MODEL requires a BRAND parent');

    }

  }

  /** Upsert PART categories from seed JSON (by `key`). */
  async seedPartCategories(): Promise<number> {
    const rows = loadPartsCategoriesSeed();
    const docs = partsSeedToCategoryDocs(rows);
    let count = 0;
    for (const doc of docs) {
      await this.categoryModel.updateOne(
        { key: doc.key, type: CategoryTypeEnum.PART },
        { $set: doc, $unset: { name: '' } },
        { upsert: true },
      );
      count += 1;
    }
    await this.mergeRetiredPartCategories();
    return count;
  }

  /**
   * Fold overlapping part categories into a broader one and drop the old row.
   * Existing listings move with them.
   */
  private async mergeRetiredPartCategories() {
    const into: Record<string, string> = {
      rims: 'wheels_tires',
      batteries: 'electrical',
      sensors: 'electrical',
      electronics: 'electrical',
      filters: 'consumables',
      oils_fluids: 'consumables',
      belts_rollers: 'consumables',
      spark_plugs: 'consumables',
    };
    const parts = this.categoryModel.db.collection(COLLECTIONS.PARTS);

    for (const [fromKey, toKey] of Object.entries(into)) {
      const from = await this.categoryModel
        .findOne({ key: fromKey, type: CategoryTypeEnum.PART })
        .select('_id')
        .lean();
      if (!from) continue;
      const to = await this.categoryModel
        .findOne({ key: toKey, type: CategoryTypeEnum.PART })
        .select('_id')
        .lean();
      if (!to) continue;
      await parts.updateMany(
        { category: from._id },
        { $set: { category: to._id } },
      );
      await this.categoryModel.deleteOne({ _id: from._id });
    }
  }

  /**
   * Upsert car brands and their main models.
   * Existing brands are matched by key or localized name so Chevrolet
   * (and others already in the database) gain models instead of duplicates.
   */
  async seedVehicleCatalog(): Promise<number> {
    const brands = loadVehicleCatalogSeed();
    let count = 0;

    for (const row of brands) {
      const names = {
        en: row.en.trim(),
        ru: row.ru.trim(),
        uz: row.uz.trim(),
      };
      const brand = await this.categoryModel.findOneAndUpdate(
        {
          type: CategoryTypeEnum.BRAND,
          $or: [
            { key: row.key },
            { 'names.en': exactNameRegex(names.en) },
            { 'names.ru': exactNameRegex(names.ru) },
            { 'names.uz': exactNameRegex(names.uz) },
          ],
        },
        {
          $set: {
            key: row.key,
            type: CategoryTypeEnum.BRAND,
            parentId: null,
            names,
            iconUrl: '',
          },
          $unset: { name: '' },
        },
        { upsert: true, new: true },
      );
      count += 1;

      for (const modelName of row.models) {
        const label = modelName.trim();
        if (!label) continue;
        const modelKey = slugModelKey(row.key, label);
        const modelNames = { en: label, ru: label, uz: label };
        await this.categoryModel.updateOne(
          {
            type: CategoryTypeEnum.MODEL,
            parentId: brand._id,
            $or: [
              { key: modelKey },
              { 'names.en': exactNameRegex(label) },
            ],
          },
          {
            $set: {
              key: modelKey,
              type: CategoryTypeEnum.MODEL,
              parentId: brand._id,
              names: modelNames,
              iconUrl: '',
            },
            $unset: { name: '' },
          },
          { upsert: true },
        );
        count += 1;
      }
    }

    return count;
  }

}

