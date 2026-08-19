import { ActionsHandler, ActionsScope, messageEditor } from 'src/bot/utils';
import { Markup } from 'telegraf';
import { mainActionsScope as adminMainActionsScope } from '../admin';
import { adminsActionsScope } from './admins.actions';

export const main = ActionsHandler.create({
  id: 'main',
  params: { isFromInner: Boolean },
  getTitle: ({ isFromInner }) => (isFromInner ? '⬅️ Back' : '🏠 Home'),
  async handler(context) {
    const adminKeyboard = adminMainActionsScope.makeKeyboard(
      context,
      ['advertisements', 'categories'],
      {
        advertisements: { isFromInner: false },
        categories: { isFromInner: false },
      },
    );

    const adminsKeyboard = adminsActionsScope.makeKeyboard(
      context,
      ['getAdmins'],
      {
        getAdmins: { isFromInner: false, page: 1 },
      },
    );

    const keyboard = [...adminKeyboard, ...adminsKeyboard];

    const reply = messageEditor(context);

    await reply('🏠 Home', Markup.inlineKeyboard(keyboard, { columns: 2 }));
  },
});

export const mainActionsScope = new ActionsScope({
  main,
});
