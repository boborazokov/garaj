import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { AppSettings, APP_SETTINGS_ID, ContactInfo } from '../schema';

const DEFAULT_SUPPORT_EMAIL = 'support@myauto.uz';
const DEFAULT_SUPPORT_PHONE = '+998 95 384 10 00';

/** Missing values mean review-before-publish. An explicit false stays off. */
export function isProductModerationOn(
  stored: boolean | null | undefined,
): boolean {
  return stored !== false;
}

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
          productModerationEnabled: true,
          supportEmail: DEFAULT_SUPPORT_EMAIL,
          supportPhone: DEFAULT_SUPPORT_PHONE,
        })
      ).toObject();
    }
    return this.withContactDefaults(doc as AppSettings);
  }

  /** Fill contacts once for documents created before these fields existed. */
  private async withContactDefaults(doc: AppSettings): Promise<AppSettings> {
    const patch: Partial<AppSettings> = {};
    if (doc.supportEmail == null) patch.supportEmail = DEFAULT_SUPPORT_EMAIL;
    if (doc.supportPhone == null) patch.supportPhone = DEFAULT_SUPPORT_PHONE;
    if (Object.keys(patch).length === 0) return doc;
    const updated = await this.settingsModel
      .findByIdAndUpdate(APP_SETTINGS_ID, { $set: patch }, { new: true })
      .lean();
    return (updated ?? { ...doc, ...patch }) as AppSettings;
  }

  async getContactInfo(): Promise<ContactInfo> {
    const settings = await this.getSettings();
    return {
      supportEmail: (settings.supportEmail ?? '').trim(),
      supportPhone: (settings.supportPhone ?? '').trim(),
    };
  }

  async setContactInfo(email: string, phone: string): Promise<AppSettings> {
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      {
        $set: {
          supportEmail: email.trim(),
          supportPhone: phone.trim(),
        },
      },
      { new: true, upsert: true },
    );
    return updated!;
  }

  async isProductModerationEnabled(): Promise<boolean> {
    const settings = await this.getSettings();
    return isProductModerationOn(settings.productModerationEnabled);
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
