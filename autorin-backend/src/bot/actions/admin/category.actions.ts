import { Types } from 'mongoose';
import { Markup } from 'telegraf';
import { categoryModel } from 'src/bot/providers';
import { categoryInfo } from 'src/bot/templates';
import { ADMIN_SCENES } from 'src/bot/constants';
import { ActionsHandler, ActionsScope, messageEditor } from 'src/bot/utils';
import { capitalize } from 'lodash';
import {
  pickCategoryName,
  resolveCategoryNamesFromDoc,
} from 'src/modules/category/utils/category-names.util';
import { mainActionsScope } from './main.actions';

export const getCategories = ActionsHandler.create({
  id: 'getCategories',
  paginationEnabled: true,
  params: { isFromInner: Boolean, type: String, page: Number },
  getTitle: ({ isFromInner, type }) =>
    isFromInner ? '⬅️ Back' : capitalize(type),
  async handler(context, params) {
    const { page, type } = params;

    const {
      docs: categories,
      hasNextPage,
      hasPrevPage,
    } = await categoryModel.paginate({ type }, { page, limit: 10 });

    const reply = messageEditor(context);

    const mainKeyboard = mainActionsScope.makeKeyboard(
      context,
      ['categories'],
      { categories: { isFromInner: true } },
    );

    const actionsKeyboard = categoriesActionsScope.makeKeyboard(
      context,
      ['createCategory'],
      { createCategory: { type } },
    );

    if (!categories.length) {
      await reply(
        `No categories found for ${type.toLowerCase()}`,
        Markup.inlineKeyboard([mainKeyboard, actionsKeyboard]),
      );
    } else {
      const paginationKeyboard = getCategories.makePaginationKeyboard({
        pagination: { hasNextPage, hasPrevPage },
        params,
      });

      const categoriesKeyboard = categories.map((cat) => ({
        text: pickCategoryName(resolveCategoryNamesFromDoc(cat), 'ru'),
        callback_data: getCategory.buildCallback({
          categoryId: cat._id,
          isFromInner: true,
        }),
      }));

      await reply(
        '📂 Categories',
        Markup.inlineKeyboard(
          [
            ...mainKeyboard,
            ...actionsKeyboard,
            ...paginationKeyboard,
            ...categoriesKeyboard,
          ],
          { columns: 2 },
        ),
      );
    }
  },
});

export const createCategory = ActionsHandler.create({
  id: 'createCategory',
  params: { type: String },
  getTitle: ({ type }) => `➕ Create ${type.toLowerCase()} category`,
  async handler(context, { type }) {
    await context.scene.enter(ADMIN_SCENES.CATEGORY_FORM, {
      type,
      parentId: null,
      category: { name: '', iconUrl: '' },
    });
  },
});

export const getCategory = ActionsHandler.create({
  id: 'getCategory',
  params: { categoryId: Types.ObjectId, isFromInner: Boolean },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '📂 Category info'),
  async handler(context, { categoryId }) {
    const foundCategory = await categoryModel.findById(categoryId);

    const reply = messageEditor(context);

    if (!foundCategory) {
      const keyboard = mainActionsScope.makeKeyboard(context, ['categories'], {
        categories: { isFromInner: true },
      });

      await reply('Category not found', Markup.inlineKeyboard(keyboard));
      return;
    }

    let parentLine = '';
    if (foundCategory.parentId) {
      const parent = await categoryModel.findById(foundCategory.parentId).lean();
      if (parent) {
        const parentLabel = pickCategoryName(
          resolveCategoryNamesFromDoc(parent),
          'ru',
        );
        parentLine = `\n🔗 Parent: ${parentLabel} (${parent.type})`;
      }
    }

    const categoryLabel = pickCategoryName(
      resolveCategoryNamesFromDoc(foundCategory),
      'ru',
    );
    const categoryInfoString =
      categoryInfo({
        name: categoryLabel,
        iconUrl: process.env.MINIO_URL + '/' + foundCategory.iconUrl,
      }) + parentLine;

    const categoryParams = { categoryId: foundCategory._id };
    const categoriesParams = {
      isFromInner: true,
      page: 1,
      type: foundCategory.type,
    };

    const keyboard = categoriesActionsScope.makeKeyboard(
      context,
      ['getCategories', 'deleteCategory', 'updateCategory'],
      {
        getCategories: categoriesParams,
        deleteCategory: categoryParams,
        updateCategory: categoryParams,
      },
    );

    await reply(categoryInfoString, Markup.inlineKeyboard(keyboard));
  },
});

export const deleteCategory = ActionsHandler.create({
  id: 'deleteCategory',
  params: { categoryId: Types.ObjectId },
  getTitle: () => '🗑️ Delete',
  async handler(context, { categoryId }) {
    const keyboard = categoriesActionsScope.makeKeyboard(
      context,
      ['confirmCategoryDelete', 'cancelCategoryDelete'],
      {
        confirmCategoryDelete: { categoryId },
        cancelCategoryDelete: { categoryId },
      },
    );

    const reply = messageEditor(context);

    await reply(
      '⚠️ Are you sure you want to delete this category?',
      Markup.inlineKeyboard(keyboard),
    );
  },
});

const confirmCategoryDelete = ActionsHandler.create({
  id: 'confirmCategoryDelete',
  params: { categoryId: Types.ObjectId },
  getTitle: () => '✅ Confirm',
  async handler(context, { categoryId }) {
    const deletedCategory = await categoryModel.findByIdAndDelete(categoryId);

    if (!deletedCategory) {
      await context.reply('❌ Category not found');
      return;
    }

    const categoriesParams = {
      isFromInner: true,
      page: 1,
      type: deletedCategory.type,
    };

    const keyboard = categoriesActionsScope.makeKeyboard(
      context,
      ['getCategories'],
      { getCategories: categoriesParams },
    );

    const reply = messageEditor(context);

    await reply('✅ Category deleted', Markup.inlineKeyboard(keyboard));
  },
});

const cancelCategoryDelete = ActionsHandler.create({
  id: 'cancelCategoryDelete',
  params: { categoryId: Types.ObjectId },
  getTitle: () => '❌ Cancel',
  async handler(context, { categoryId }) {
    const keyboard = categoriesActionsScope.makeKeyboard(
      context,
      ['getCategory'],
      {
        getCategory: { categoryId, isFromInner: true },
      },
    );

    const reply = messageEditor(context);

    await reply(
      '❌ Category deletion canceled',
      Markup.inlineKeyboard(keyboard),
    );
  },
});

export const updateCategory = ActionsHandler.create({
  id: 'updateCategory',
  params: { categoryId: Types.ObjectId },
  getTitle: () => '📝 Edit',
  async handler(context, { categoryId }) {
    const foundCategory = await categoryModel.findById(categoryId).lean();
    if (!foundCategory) {
      await context.reply('Category not found');
      return;
    }
    await context.scene.enter(ADMIN_SCENES.CATEGORY_FORM, {
      type: foundCategory.type,
      categoryId: foundCategory._id,
      parentId: foundCategory.parentId ?? null,
      category: {
        name: pickCategoryName(resolveCategoryNamesFromDoc(foundCategory), 'ru'),
        iconUrl: foundCategory.iconUrl ?? '',
      },
    });
  },
});

export const categoriesActionsScope = new ActionsScope({
  getCategories,
  createCategory,
  getCategory,
  updateCategory,
  deleteCategory,
  confirmCategoryDelete,
  cancelCategoryDelete,
});
