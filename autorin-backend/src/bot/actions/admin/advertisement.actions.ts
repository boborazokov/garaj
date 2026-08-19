import { Types } from 'mongoose';
import { Markup } from 'telegraf';
import { advertisementModel } from 'src/bot/providers';
import { advertisementInfo } from 'src/bot/templates';
import { ADMIN_SCENES, SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { ActionsHandler, ActionsScope, messageEditor } from 'src/bot/utils';
import { capitalize } from 'lodash';
import { mainActionsScope } from './main.actions';

export const getAdvertisements = ActionsHandler.create({
  id: 'getAdvertisements',
  paginationEnabled: true,
  params: { isFromInner: Boolean, type: String, page: Number },
  getTitle: ({ isFromInner, type }) =>
    isFromInner ? '⬅️ Back' : capitalize(type),
  async handler(context, params) {
    const { page, type } = params;

    const {
      docs: advertisements,
      hasNextPage,
      hasPrevPage,
    } = await advertisementModel.paginate({ type }, { page, limit: 10 });

    const reply = messageEditor(context);

    const mainKeyboard = mainActionsScope.makeKeyboard(
      context,
      ['advertisements'],
      { advertisements: { isFromInner: true } },
    );

    const actionsKeyboard = advertisementsActionsScope.makeKeyboard(
      context,
      ['createAdvertisement'],
      { createAdvertisement: { type } },
    );

    if (!advertisements.length) {
      await reply(
        `No advertisements found for ${type.toLowerCase()}`,
        Markup.inlineKeyboard([mainKeyboard, actionsKeyboard]),
      );
    } else {
      const paginationKeyboard = getAdvertisements.makePaginationKeyboard({
        pagination: { hasNextPage, hasPrevPage },
        params,
      });

      const categoriesKeyboard = advertisements.map(({ title, _id }) => ({
        text: title,
        callback_data: getAdvertisement.buildCallback({
          advertisementId: _id,
          isFromInner: true,
        }),
      }));

      await reply(
        '📂 Advertisements',
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

export const createAdvertisement = ActionsHandler.create({
  id: 'createAdvertisement',
  params: { type: String },
  getTitle: ({ type }) => `➕ Create ${type.toLowerCase()} advertisement`,
  async handler(context, { type }) {
    await context.scene.enter(ADMIN_SCENES.CATEGORY_FORM, { type });
  },
});

export const getAdvertisement = ActionsHandler.create({
  id: 'getAdvertisement',
  params: { advertisementId: Types.ObjectId, isFromInner: Boolean },
  getTitle: ({ isFromInner }) =>
    isFromInner ? '⬅️ Back' : '📂 Advertisement info',
  async handler(context, { advertisementId }) {
    const foundAdvertisement =
      await advertisementModel.findById(advertisementId);

    const reply = messageEditor(context);

    if (!foundAdvertisement) {
      const keyboard = mainActionsScope.makeKeyboard(
        context,
        ['advertisements'],
        { advertisements: { isFromInner: true } },
      );

      await reply('Advertisement not found', Markup.inlineKeyboard(keyboard));
      return;
    }

    const categoryInfoString = advertisementInfo({
      title: foundAdvertisement.title,
      bannerImageUrl: foundAdvertisement.bannerImageUrl,
    });

    const categoryParams = { advertisementId: foundAdvertisement._id };
    const advertisementsParams = {
      isFromInner: true,
      page: 1,
      type: foundAdvertisement.type,
    };

    const keyboard = advertisementsActionsScope.makeKeyboard(
      context,
      ['getAdvertisements', 'deleteAdvertisement', 'updateAdvertisement'],
      {
        getAdvertisements: advertisementsParams,
        deleteAdvertisement: categoryParams,
        updateAdvertisement: categoryParams,
      },
    );

    await reply(categoryInfoString, {
      ...Markup.inlineKeyboard(keyboard),
      parse_mode: 'HTML',
    });
  },
});

export const deleteAdvertisement = ActionsHandler.create({
  id: 'deleteAdvertisement',
  params: { advertisementId: Types.ObjectId },
  getTitle: () => '🗑️ Delete',
  async handler(context, { advertisementId }) {
    const keyboard = advertisementsActionsScope.makeKeyboard(
      context,
      ['confirmAdvertisementDelete', 'cancelAdvertisementDelete'],
      {
        confirmAdvertisementDelete: { advertisementId },
        cancelAdvertisementDelete: { advertisementId },
      },
    );

    const reply = messageEditor(context);

    await reply(
      '⚠️ Are you sure you want to delete this advertisement`,?',
      Markup.inlineKeyboard(keyboard),
    );
  },
});

const confirmAdvertisementDelete = ActionsHandler.create({
  id: 'confirmAdvertisementDelete',
  params: { advertisementId: Types.ObjectId },
  getTitle: () => '✅ Confirm',
  async handler(context, { advertisementId }) {
    const deletedAdvertisement =
      await advertisementModel.findByIdAndDelete(advertisementId);

    if (!deletedAdvertisement) {
      await context.reply('❌ Advertisement not found');
      return;
    }

    const advertisementsParams = {
      isFromInner: true,
      page: 1,
      type: deletedAdvertisement.type,
    };

    const keyboard = advertisementsActionsScope.makeKeyboard(
      context,
      ['getAdvertisements'],
      { getAdvertisements: advertisementsParams },
    );

    const reply = messageEditor(context);

    await reply('✅ Advertisement deleted', Markup.inlineKeyboard(keyboard));
  },
});

const cancelAdvertisementDelete = ActionsHandler.create({
  id: 'cancelAdvertisementDelete',
  params: { advertisementId: Types.ObjectId },
  getTitle: () => '❌ Cancel',
  async handler(context, { advertisementId }) {
    const keyboard = advertisementsActionsScope.makeKeyboard(
      context,
      ['getAdvertisement'],
      {
        getAdvertisement: { advertisementId, isFromInner: true },
      },
    );

    const reply = messageEditor(context);

    await reply(
      '❌ Advertisement deletion canceled',
      Markup.inlineKeyboard(keyboard),
    );
  },
});

export const updateAdvertisement = ActionsHandler.create({
  id: 'updateAdvertisement',
  params: { advertisementId: Types.ObjectId },
  getTitle: () => '📝 Edit',
  async handler(context, { advertisementId }) {
    await context.scene.enter(SUPER_ADMIN_SCENES.ADMIN_FORM, {
      advertisementId,
    });
  },
});

export const advertisementsActionsScope = new ActionsScope({
  getAdvertisements,
  createAdvertisement,
  getAdvertisement,
  updateAdvertisement,
  deleteAdvertisement,
  confirmAdvertisementDelete,
  cancelAdvertisementDelete,
});
