import axios from 'axios';
import { Types } from 'mongoose';
import { getCategory } from 'src/bot/actions/admin';
import { ADMIN_SCENES } from 'src/bot/constants';
import { categoryModel, minioService } from 'src/bot/providers';
import { Catalog, FILE_TYPES_EXTENSIONS } from 'src/constants';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import {
  pickCategoryName,
  resolveCategoryNamesFromDoc,
} from 'src/modules/category/utils/category-names.util';
import { Markup } from 'telegraf';
import { Composer } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';

type CategoryDraft = {
  name: string;
  iconUrl: string;
};

export type CategoryFormState = {
  type: CategoryTypeEnum;
  categoryId?: Types.ObjectId;
  parentId?: Types.ObjectId | null;
  category: CategoryDraft;
};

type Context = WizardContext & { scene: { state: CategoryFormState } };

function needsParentPicker(type: CategoryTypeEnum): boolean {
  return type === CategoryTypeEnum.MODEL || type === CategoryTypeEnum.PART;
}

function parentTypeFor(type: CategoryTypeEnum): CategoryTypeEnum | null {
  if (type === CategoryTypeEnum.MODEL) return CategoryTypeEnum.BRAND;
  if (type === CategoryTypeEnum.PART) return CategoryTypeEnum.MODEL;
  return null;
}

async function askCategoryName(context: Context) {
  await context.reply('✏️ Enter category name');
}

/** Step 1: parent picker for MODEL / PART, or name for BRAND. */
export async function stepEnter(context: Context) {
  const state = context.scene.state;
  state.category = state.category ?? { name: '', iconUrl: '' };

  if (state.categoryId) {
    await askCategoryName(context);
    return context.wizard.next();
  }

  const type = state.type;
  if (!needsParentPicker(type)) {
    state.parentId = null;
    await askCategoryName(context);
    return context.wizard.next();
  }

  const parentType = parentTypeFor(type);
  const parents = await categoryModel
    .find({ type: parentType })
    .sort({ name: 1 })
    .limit(40)
    .lean();

  if (type === CategoryTypeEnum.MODEL && parents.length === 0) {
    await context.reply(
      '❌ No brands yet. Create a BRAND category first, then add models.',
    );
    await context.scene.enter(ADMIN_SCENES.MAIN);
    return;
  }

  if (type === CategoryTypeEnum.PART && parents.length === 0) {
    state.parentId = null;
    await context.reply(
      'ℹ️ No models in catalog — part will be global (not tied to a model).',
    );
    await askCategoryName(context);
    return context.wizard.next();
  }

  const rows = parents.map((p) => [
    Markup.button.callback(
      pickCategoryName(resolveCategoryNamesFromDoc(p), 'ru'),
      `cat_parent:${p._id.toString()}`,
    ),
  ]);

  if (type === CategoryTypeEnum.PART) {
    rows.push([
      Markup.button.callback(
        '⏭ Global part (no model)',
        'cat_parent:none',
      ),
    ]);
  }

  rows.push([Markup.button.callback('❌ Cancel', 'cat_cancel')]);

  const hint =
    type === CategoryTypeEnum.MODEL
      ? '🚗 Select the brand for this model:'
      : '🔗 Optionally link this part category to a model:';

  await context.reply(hint, Markup.inlineKeyboard(rows));
}

/** Handles parent selection callbacks (still on step 1). */
export const selectParentComposer = new Composer<Context>();

selectParentComposer.action('cat_cancel', async (context) => {
  await context.scene.enter(ADMIN_SCENES.MAIN);
});

selectParentComposer.action(/^cat_parent:(.+)$/, async (context) => {
  const raw = context.match[1];
  if (raw !== 'none') {
    context.scene.state.parentId = new Types.ObjectId(raw);
  } else {
    context.scene.state.parentId = null;
  }
  await askCategoryName(context);
  return context.wizard.selectStep(1);
});

/** Step 2: category name. */
export async function stepName(context: Context) {
  if (context.message && 'text' in context.message) {
    context.scene.state.category.name = context.message.text.trim();
    await context.reply('📤 Upload category icon (photo, max 5MB)');
    return context.wizard.next();
  }
  await context.reply('Please send the category name as text.');
}

/** Step 3: icon upload + save. */
export async function stepIcon(context: Context) {
  if (!context.message || !('photo' in context.message)) {
    await context.reply('Please send a photo for the icon.');
    return;
  }

  const { photo } = context.message;
  const fileId = photo[photo.length - 1].file_id;
  const fileLink = await context.telegram.getFileLink(fileId);
  const fileStream = await axios.get(fileLink.href, { responseType: 'stream' });

  if (!fileStream) {
    await context.reply('Invalid file. Try again.');
    return;
  }

  let fileExtension = '';
  const pathnameSlices = fileStream?.config?.url?.split('/');

  if (!pathnameSlices) {
    await context.reply('Invalid file. Try again.');
    return;
  }

  const extensionInPathname =
    pathnameSlices[pathnameSlices.length - 1].split('.')[1];

  if (extensionInPathname) {
    fileExtension = extensionInPathname;
  } else {
    const fileCatalog = pathnameSlices[pathnameSlices.length - 2];
    fileExtension = FILE_TYPES_EXTENSIONS[fileCatalog] || 'png';
  }

  if (!fileExtension) {
    await context.reply('Invalid file. Try again.');
    return;
  }

  const fileName = `${Date.now()}.${fileExtension}`;
  const uploadedFileUrl = await minioService.uploadFile({
    catalog: Catalog.CATEGORIES_ICONS,
    compress: false,
    fileBuffer: fileStream.data,
    fileKey: fileName,
    fileMimetype: fileStream.headers['content-type'],
  });

  if (!uploadedFileUrl) {
    await context.reply('Invalid file. Try again.');
    return;
  }

  context.scene.state.category.iconUrl = uploadedFileUrl;

  const { type, category, categoryId, parentId } = context.scene.state;

  if (type === CategoryTypeEnum.MODEL && !parentId) {
    await context.reply('❌ Model must be linked to a brand.');
    return;
  }

  const label = category.name.trim();
  const payload = {
    type,
    names: { en: label, ru: label, uz: label },
    iconUrl: category.iconUrl,
    parentId:
      type === CategoryTypeEnum.BRAND ? null : (parentId ?? null),
  };

  let savedId: Types.ObjectId;

  if (categoryId) {
    await categoryModel.updateOne({ _id: categoryId }, payload);
    savedId = categoryId;
  } else {
    const created = await categoryModel.create(payload);
    savedId = created._id as Types.ObjectId;
  }

  await context.reply('✅ Category saved');
  await context.scene.enter(ADMIN_SCENES.MAIN);

  await getCategory.handler(context, {
    isFromInner: true,
    categoryId: savedId,
  });
}
