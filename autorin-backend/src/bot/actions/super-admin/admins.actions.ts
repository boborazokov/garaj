import { Types } from 'mongoose';
import { Markup } from 'telegraf';

import { userModel } from 'src/bot/providers';
import { adminInfo } from 'src/bot/templates';
import { SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { UserRoleEnum } from 'src/modules/user/enums';
import { ActionsHandler, ActionsScope, messageEditor } from 'src/bot/utils';
import { mainActionsScope } from './main.actions';

export const getAdmins = ActionsHandler.create({
  id: 'getAdmins',
  paginationEnabled: true,
  params: { isFromInner: Boolean, page: Number },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '👥 Admins'),
  async handler(context, params) {
    const {
      docs: admins,
      hasNextPage,
      hasPrevPage,
    } = await userModel.paginate(
      { role: UserRoleEnum.ADMIN },
      { page: params.page, limit: 10 },
    );

    const reply = messageEditor(context);

    const mainKeyboard = mainActionsScope.makeKeyboard(context, ['main'], {
      main: { isFromInner: true },
    });

    const actionsKeyboard = adminsActionsScope.makeKeyboard(
      context,
      ['createAdmin'],
      { createAdmin: {} },
    );

    const commonActionsKeyboard = [...mainKeyboard, ...actionsKeyboard];

    if (!admins.length) {
      await reply('No admins', Markup.inlineKeyboard(commonActionsKeyboard));
    } else {
      const paginationKeyboard = getAdmins.makePaginationKeyboard({
        pagination: { hasNextPage, hasPrevPage },
        params,
      });

      const adminsKeyboard = admins.map(({ name, _id }) => ({
        text: name,
        callback_data: getAdmin.buildCallback({
          adminId: _id,
          isFromInner: true,
        }),
      }));

      await reply(
        '👥 Admins',
        Markup.inlineKeyboard(
          [...commonActionsKeyboard, ...paginationKeyboard, ...adminsKeyboard],
          { columns: 2 },
        ),
      );
    }
  },
});

export const createAdmin = ActionsHandler.create({
  id: 'createAdmin',
  params: {},
  getTitle: () => '👤 Create admin',
  async handler(context) {
    await context.scene.enter(SUPER_ADMIN_SCENES.ADMIN_FORM);
  },
});

export const getAdmin = ActionsHandler.create({
  id: 'getAdmin',
  params: { adminId: Types.ObjectId, isFromInner: Boolean },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '👤 Admin info'),
  async handler(context, { adminId }) {
    const foundAdmin = await userModel.findOne({
      _id: adminId,
      role: UserRoleEnum.ADMIN,
    });

    const reply = messageEditor(context);

    if (!foundAdmin) {
      const keyboard = adminsActionsScope.makeKeyboard(context, ['getAdmins'], {
        getAdmins: { isFromInner: true, page: 1 },
      });

      await reply('Admin not found', Markup.inlineKeyboard(keyboard));
      return;
    }

    const adminInfoString = adminInfo({
      name: foundAdmin.name,
      phone: foundAdmin.phone,
      tgId: foundAdmin.tgId,
    });

    const keyboard = adminsActionsScope.makeKeyboard(
      context,
      ['getAdmins', 'deleteAdmin', 'updateAdmin'],
      {
        getAdmins: { isFromInner: true, page: 1 },
        deleteAdmin: { adminId: foundAdmin._id },
        updateAdmin: { adminId: foundAdmin._id },
      },
    );

    await reply(adminInfoString, Markup.inlineKeyboard(keyboard));
  },
});

export const deleteAdmin = ActionsHandler.create({
  id: 'deleteAdmin',
  params: { adminId: Types.ObjectId },
  getTitle: () => '🗑️ Delete',
  async handler(context, { adminId }) {
    const keyboard = adminsActionsScope.makeKeyboard(
      context,
      ['confirmAdminDelete', 'cancelAdminDelete'],
      {
        confirmAdminDelete: { adminId },
        cancelAdminDelete: { adminId },
      },
    );

    const reply = messageEditor(context);

    await reply(
      '⚠️ Are you sure you want to delete this admin?',
      Markup.inlineKeyboard(keyboard),
    );
  },
});

const confirmAdminDelete = ActionsHandler.create({
  id: 'confirmAdminDelete',
  params: { adminId: Types.ObjectId },
  getTitle: () => '✅ Confirm',
  async handler(context, { adminId }) {
    const foundAdmin = await userModel.findOne({
      _id: adminId,
      role: UserRoleEnum.ADMIN,
    });

    if (!foundAdmin) {
      await context.reply('❌ Admin not found');
      return;
    }

    await userModel.deleteOne({ _id: adminId });

    const keyboard = adminsActionsScope.makeKeyboard(context, ['getAdmins'], {
      getAdmins: { isFromInner: true, page: 1 },
    });

    const reply = messageEditor(context);

    await reply('✅ Admin deleted', Markup.inlineKeyboard(keyboard));
  },
});

const cancelAdminDelete = ActionsHandler.create({
  id: 'cancelAdminDelete',
  params: { adminId: Types.ObjectId },
  getTitle: () => '❌ Cancel',
  async handler(context, { adminId }) {
    const keyboard = adminsActionsScope.makeKeyboard(context, ['getAdmin'], {
      getAdmin: { adminId, isFromInner: true },
    });

    const reply = messageEditor(context);

    await reply('❌ Admin deletion canceled', Markup.inlineKeyboard(keyboard));
  },
});

export const updateAdmin = ActionsHandler.create({
  id: 'updateAdmin',
  params: { adminId: Types.ObjectId },
  getTitle: () => '📝 Edit',
  async handler(context, { adminId }) {
    await context.scene.enter(SUPER_ADMIN_SCENES.ADMIN_FORM, { adminId });
  },
});

export const adminsActionsScope = new ActionsScope({
  createAdmin,
  getAdmins,
  getAdmin,
  updateAdmin,
  deleteAdmin,
  confirmAdminDelete,
  cancelAdminDelete,
});
