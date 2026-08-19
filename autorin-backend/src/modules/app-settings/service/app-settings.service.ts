import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { AppSettings, APP_SETTINGS_ID } from '../schema';

@Injectable()
export class AppSettingsService {
  constructor(
    @InjectModel(COLLECTIONS.APP_SETTINGS)
    private readonly settingsModel: Model<AppSettings>,
  ) {}

  async getSettings(): Promise<AppSettings> {
    let doc = await this.settingsModel.findById(APP_SETTINGS_ID).lean();
    if (!doc) {
      doc = (
        await this.settingsModel.create({
          _id: APP_SETTINGS_ID,
          productModerationEnabled: false,
        })
      ).toObject();
    }
    return doc as AppSettings;
  }

  async isProductModerationEnabled(): Promise<boolean> {
    const settings = await this.getSettings();
    return settings.productModerationEnabled === true;
  }

  async setProductModerationEnabled(enabled: boolean): Promise<AppSettings> {
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      { $set: { productModerationEnabled: enabled } },
      { new: true, upsert: true },
    );
    return updated!;
  }
}
