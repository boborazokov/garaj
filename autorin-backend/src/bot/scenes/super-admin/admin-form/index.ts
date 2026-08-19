import { SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { Scenes } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';
import * as composers from './admin-form.composers';

export const adminFormScene = new Scenes.WizardScene<WizardContext>(
  SUPER_ADMIN_SCENES.ADMIN_FORM,
  ...Object.values(composers),
);
