import { ADMIN_SCENES } from 'src/bot/constants';
import { Scenes } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';
import * as composers from './advertisement-form.composers';

export const advertisementFormScene = new Scenes.WizardScene<WizardContext>(
  ADMIN_SCENES.ADVERTISEMENT_FORM,
  ...Object.values(composers),
);
