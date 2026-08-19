import { Context, Scenes, session, Telegraf } from 'telegraf';
import { scenes } from './scenes';
import { ADMIN_SCENES, SUPER_ADMIN_SCENES } from './constants';
import { Update } from 'telegraf/typings/core/types/typegram';
import { SceneContext } from 'telegraf/typings/scenes';
import * as dotenv from 'dotenv';
import { userModel } from './providers';
dotenv.config();

export function initBot(token: string): Telegraf<Context> {
  const bot: Telegraf<Context<Update> & SceneContext> = new Telegraf(token);

  const stage = new Scenes.Stage(scenes);

  bot.use(session());
  bot.use(stage.middleware());

  bot.start(async (context) => {
    const isSuperAdmin = context.from.id === Number(process.env.SUPER_ADMIN_ID);

    if (isSuperAdmin) {
      await context.scene.enter(SUPER_ADMIN_SCENES.MAIN);
      return;
    }

    const isAdmin = await userModel.exists({
      tgId: context.from.id,
    });

    if (isAdmin) {
      await context.scene.enter(ADMIN_SCENES.MAIN);
      return;
    }

    await context.reply(
      'You are not authorized to use this bot. Please contact the administrator.',
    );
  });

  return bot;
}
