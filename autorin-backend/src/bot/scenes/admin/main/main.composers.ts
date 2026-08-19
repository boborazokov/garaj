import {
  advertisementsActionsScope,
  categoriesActionsScope,
  main,
  mainActionsScope,
} from 'src/bot/actions/admin';
import { COMMON_COMMANDS } from 'src/bot/constants';
import { Composer } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';

export const mainComposer = new Composer<WizardContext>();

mainActionsScope.initForComposer(mainComposer);
advertisementsActionsScope.initForComposer(mainComposer);
categoriesActionsScope.initForComposer(mainComposer);

mainComposer.hears(COMMON_COMMANDS.START, async (context) => {
  await main.handler(context, { isFromInner: false });
});
