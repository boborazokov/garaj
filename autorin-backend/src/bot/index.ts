import * as dotenv from 'dotenv';
import { ConsoleLogger } from '@nestjs/common';
import { initBot } from './init-bot';

dotenv.config();

export async function startBot() {
  const logger = new ConsoleLogger('Telegram Bot');

  logger.log('Starting bot...');

  if (!process.env.BOT_TOKEN) {
    throw new Error('BOT_TOKEN is not defined');
  }

  const bot = initBot(process.env.BOT_TOKEN);

  await bot.launch(() => {
    logger.log('Bot started');
  });
}
