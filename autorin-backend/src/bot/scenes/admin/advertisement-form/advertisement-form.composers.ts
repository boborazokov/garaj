import { Types } from 'mongoose';
import { getAdvertisement, createAdvertisement } from 'src/bot/actions/admin';
import { SUPER_ADMIN_SCENES } from 'src/bot/constants';
import { advertisementModel } from 'src/bot/providers';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { UserRoleEnum } from 'src/modules/user/enums';
import { Composer } from 'telegraf';
import { WizardContext } from 'telegraf/typings/scenes';

type State = {
  type: CategoryTypeEnum;
  advertisementId: string | Types.ObjectId;
  advertisement: {
    bannerImageUrl: string;
    title: string;
    link: string;
  };
};

type Context = WizardContext & { scene: { state: State } };

export const mainComposer = new Composer<Context>();

mainComposer.action(createAdvertisement.matcher, async (context) => {
  context.scene.state = {
    advertisementId: context.scene.state.advertisementId,
    type: context.scene.state.type,
    advertisement: {
      bannerImageUrl: '',
      title: '',
      link: '',
    },
  };

  await context.reply(
    '🖼 Please enter the banner image URL for the advertisement (must start with https://)',
  );

  context.wizard.next();
});

export const getAdvertisementBannerUrl = new Composer<Context>();

getAdvertisementBannerUrl.on('text', async (context) => {
  const isValidUrl = new URL(context.message.text)?.protocol === 'https:';

  if (!isValidUrl) {
    await context.reply(
      '❌ Invalid URL. Please make sure it starts with "https://".',
    );
    return;
  }

  context.scene.state.advertisement.bannerImageUrl = context.message.text;

  await context.reply('✏️ Now enter the advertisement title');

  context.wizard.next();
});

export const getAdvertisementNameComposer = new Composer<Context>();

getAdvertisementNameComposer.on('text', async (context) => {
  context.scene.state.advertisement.title = context.message.text;

  await context.reply(
    '🔗 Finally, enter the advertisement link (e.g., website or contact page)',
  );

  context.wizard.next();
});

export const getAdvertisementContactComposer = new Composer<Context>();

getAdvertisementContactComposer.on('text', async (context) => {
  const link = context.message.text;

  context.scene.state.advertisement.link = link;

  const { advertisement, advertisementId } = context.scene.state;

  if (advertisementId) {
    await advertisementModel.findByIdAndUpdate(advertisementId, {
      bannerImageUrl: advertisement.bannerImageUrl,
      title: advertisement.title,
      link: advertisement.link,
    });
  } else {
    const foundAdvertisement = await advertisementModel.findOne({
      type: context.scene.state.type,
      $or: [
        { bannerImageUrl: advertisement.bannerImageUrl },
        { link: advertisement.link },
      ],
    });

    if (foundAdvertisement) {
      if (foundAdvertisement.bannerImageUrl === advertisement.bannerImageUrl) {
        await context.reply(
          '⚠️ An advertisement with this banner image already exists.',
        );
      } else if (foundAdvertisement.link === advertisement.link) {
        await context.reply(
          '⚠️ An advertisement with this link already exists.',
        );
      }
    } else {
      const createdAdvertisement = await advertisementModel.create({
        type: context.scene.state.type,
        bannerImageUrl: advertisement.bannerImageUrl,
        title: advertisement.title,
        link: advertisement.link,
        role: UserRoleEnum.ADMIN,
      });

      context.scene.state.advertisementId = createdAdvertisement._id;
    }
  }

  await context.scene.enter(SUPER_ADMIN_SCENES.MAIN);
  await getAdvertisement.handler(context, {
    advertisementId: new Types.ObjectId(context.scene.state.advertisementId),
    isFromInner: true,
  });
});
