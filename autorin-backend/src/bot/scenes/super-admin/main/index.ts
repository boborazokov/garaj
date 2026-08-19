import { SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { Scenes } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';
import * as composers from './main.composers';

export const superAdminMainScene = new Scenes.WizardScene<WizardContext>(
  SUPER_ADMIN_SCENES.MAIN,
  ...Object.values(composers),
);
