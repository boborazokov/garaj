import { ADMIN_SCENES } from 'src/bot/constants';
import { Scenes } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';
import {
  selectParentComposer,
  stepEnter,
  stepIcon,
  stepName,
} from './category-form.composers';

export const categoryFormScene = new Scenes.WizardScene<WizardContext>(
  ADMIN_SCENES.CATEGORY_FORM,
  stepEnter,
  stepName,
  stepIcon,
);

categoryFormScene.use(selectParentComposer);
