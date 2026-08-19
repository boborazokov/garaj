import {
  main,
  mainActionsScope,
  adminsActionsScope,
} from 'src/bot/actions/super-admin';
import {
  mainActionsScope as adminMainActionsScope,
  advertisementsActionsScope,
  categoriesActionsScope,
} from 'src/bot/actions/admin';
import { COMMON_COMMANDS } from 'src/bot/constants';
import { Composer } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';

export const mainComposer = new Composer<WizardContext>();

mainActionsScope.initForComposer(mainComposer);
adminsActionsScope.initForComposer(mainComposer);
adminMainActionsScope.initForComposer(mainComposer);
categoriesActionsScope.initForComposer(mainComposer);
advertisementsActionsScope.initForComposer(mainComposer);

mainComposer.hears(COMMON_COMMANDS.START, async (context) => {
  await main.handler(context, { isFromInner: false });
});
