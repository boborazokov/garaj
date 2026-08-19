import { ActionsHandler, ActionsScope, messageEditor } from 'src/bot/utils';
import { Markup } from 'telegraf';
import {
  advertisementsActionsScope,
  getAdvertisements,
} from './advertisement.actions';
import { getCategories } from './category.actions';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { main as superAdminMain } from '../super-admin';

export const main = ActionsHandler.create({
  id: 'main',
  params: { isFromInner: Boolean },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '🏠 Home'),
  async handler(context, params) {
    const isSuperAdmin =
      process.env.SUPER_ADMIN_ID === context.from?.id?.toString();

    if (isSuperAdmin) {
      await superAdminMain.handler(context, params);
      return;
    }

    const keyboard = mainActionsScope.makeKeyboard(
      context,
      ['advertisements', 'categories'],
      {
        advertisements: { isFromInner: false },
        categories: { isFromInner: false },
      },
    );

    const reply = messageEditor(context);

    await reply('🏠 Home', Markup.inlineKeyboard(keyboard));
  },
});

export const advertisements = ActionsHandler.create({
  id: 'advertisements',
  params: { isFromInner: Boolean },
  getTitle: ({ isFromInner }) =>
    isFromInner ? '⬅️ Back' : '📢 Advertisements',
  async handler(context) {
    const reply = messageEditor(context);

    const mainKeyboard = mainActionsScope.makeKeyboard(context, ['main'], {
      main: { isFromInner: true },
    });

    const typesKeyboard = Object.values(CategoryTypeEnum).map((type) => {
      const params = {
        type,
        context,
        isFromInner: false,
        page: 1,
      };

      return {
        text: getAdvertisements.getTitle(params),
        callback_data: getAdvertisements.buildCallback(params),
      };
    });

    await reply(
      '📂 Advertisements',
      Markup.inlineKeyboard([...mainKeyboard, ...typesKeyboard], {
        columns: 2,
      }),
    );
  },
});

export const categories = ActionsHandler.create({
  id: 'categories',
  params: { isFromInner: Boolean },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '📂 Categories'),
  async handler(context) {
    const reply = messageEditor(context);

    const mainKeyboard = mainActionsScope.makeKeyboard(context, ['main'], {
      main: { isFromInner: true },
    });

    const typesKeyboard = Object.values(CategoryTypeEnum).map((type) => {
      const params = {
        type,
        context,
        isFromInner: false,
        page: 1,
      };

      return {
        text: getCategories.getTitle(params),
        callback_data: getCategories.buildCallback(params),
      };
    });

    await reply(
      '📂 Categories',
      Markup.inlineKeyboard([...mainKeyboard, ...typesKeyboard], {
        columns: 2,
      }),
    );
  },
});

export const mainActionsScope = new ActionsScope({
  main,
  advertisements,
  categories,
});
