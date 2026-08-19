import { Types } from 'mongoose';
import { createAdmin, getAdmin } from 'src/bot/actions';
import { SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { userModel } from 'src/bot/providers';
import { PASSWORD_MIN_LENGTH } from 'src/constants';
import { UserRoleEnum } from 'src/modules/user/enums';
import { normalizeUzPhone } from 'src/shared/utils/normalize-uz-phone';
import { Composer } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';

type State = {
  adminId: string | Types.ObjectId;
  admin: {
    tgId: number;
    name: string;
    phone: string;
    password: string;
  };
};

type Context = WizardContext & { scene: { state: State } };

export const mainComposer = new Composer<Context>();

mainComposer.action(createAdmin.matcher, async (context) => {
  context.scene.state = {
    adminId: context.scene.state.adminId,
    admin: {
      name: '',
      tgId: 0,
      phone: '',
      password: '',
    },
  };

  await context.reply("✏️ Enter admin's Telegram 🆔");

  context.wizard.next();
});

export const getAdminTgIdComposer = new Composer<Context>();

getAdminTgIdComposer.on('text', async (context) => {
  const isValidTgId = +context.message.text > 0;

  if (!isValidTgId) {
    await context.reply('Invalid Telegram ID. Try again.');
    return;
  }

  context.scene.state.admin.tgId = +context.message.text;

  await context.reply("✏️ Enter admin's name");

  context.wizard.next();
});

export const getAdminNameComposer = new Composer<Context>();

getAdminNameComposer.on('text', async (context) => {
  context.scene.state.admin.name = context.message.text;

  await context.reply("📤 Send admin's contact");

  context.wizard.next();
});

export const getAdminContactComposer = new Composer<Context>();

getAdminContactComposer.on('contact', async (context) => {
  const { phone_number } = context.message.contact;

  context.scene.state.admin.phone = normalizeUzPhone(phone_number);

  await context.reply(
    `✏️ Enter ${context.scene.state.admin.name}'s 🔑 password`,
  );

  context.wizard.next();
});

export const getAdminPasswordComposer = new Composer<Context>();

getAdminPasswordComposer.on('text', async (context) => {
  const isValidPassword = context.message.text.length > PASSWORD_MIN_LENGTH;

  if (!isValidPassword) {
    await context.reply('🔑 Password too short. 🔄️ Try again.');
    return;
  }

  context.scene.state.admin.password = context.message.text;

  const { admin, adminId } = context.scene.state;

  const phone = normalizeUzPhone(admin.phone);

  if (adminId) {
    const existing = await userModel.findById(adminId);
    if (existing) {
      existing.tgId = admin.tgId;
      existing.name = admin.name;
      existing.phone = phone;
      existing.password = admin.password;
      await existing.save();
    }
  } else {
    const foundAdmin = await userModel.findOne({
      $or: [{ tgId: admin.tgId }, { phone }],
    });

    if (foundAdmin) {
      if (foundAdmin.tgId === admin.tgId) {
        await context.reply('Admin with this Telegram ID already exists.');
      } else if (foundAdmin.phone === admin.phone) {
        await context.reply('Admin with this phone number already exists.');
      }
    } else {
      const createdAdmin = await userModel.create({
        tgId: admin.tgId,
        name: admin.name,
        phone,
        password: admin.password,
        role: UserRoleEnum.ADMIN,
      });

      context.scene.state.adminId = createdAdmin._id;
    }
  }

  await context.scene.enter(SUPER_ADMIN_SCENES.MAIN);
  await getAdmin.handler(context, {
    adminId: new Types.ObjectId(context.scene.state.adminId),
    isFromInner: true,
  });
});
