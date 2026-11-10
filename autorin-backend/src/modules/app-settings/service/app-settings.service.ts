import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { CategoryTypeEnum } from 'src/modules/category/enums';
import { AdvertisementPlanEnum } from 'src/modules/advertisement/enums';
import { ServicePromotionPlanEnum } from 'src/modules/service/enums/service-promotion-plan.enum';
import { AppSettings, APP_SETTINGS_ID, ContactInfo } from '../schema';

const DEFAULT_SUPPORT_EMAIL = 'support@myauto.uz';
const DEFAULT_SUPPORT_PHONE = '+998 95 384 10 00';

/** Missing values mean review-before-publish. An explicit false stays off. */
export function isProductModerationOn(
  stored: boolean | null | undefined,
): boolean {
  return stored !== false;
}

export function advertisementTariffKey(
  placement: CategoryTypeEnum,
  plan: AdvertisementPlanEnum,
): string {
  return `${placement}:${plan}`;
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
          advertisementTariffs: {},
          promotionTariffs: {},
        })
      ).toObject();
    }
    return this.withContactDefaults(doc as AppSettings);
  }

  async getAdvertisementTariffs(): Promise<Record<string, number>> {
    const settings = await this.getSettings();
    return { ...(settings.advertisementTariffs ?? {}) };
  }

  async getPromotionTariffs(): Promise<Record<string, number>> {
    const settings = await this.getSettings();
    return { ...(settings.promotionTariffs ?? {}) };
  }

  async getPromotionTariffDays(): Promise<Record<string, number>> {
    const settings = await this.getSettings();
    return { ...(settings.promotionTariffDays ?? {}) };
  }

  async getPromotionTariffDiscounts(): Promise<Record<string, number>> {
    const settings = await this.getSettings();
    return { ...(settings.promotionTariffDiscounts ?? {}) };
  }

  private assertPromotionDays(days: number | null | undefined): number | null {
    if (days == null) return null;
    const value = Math.round(Number(days));
    if (!Number.isFinite(value) || value < 1 || value > 365) {
      throw new BadRequestException('days must be between 1 and 365');
    }
    return value;
  }

  private assertDiscountPercent(
    discountPercent: number | null | undefined,
  ): number | null {
    if (discountPercent == null) return null;
    const value = Math.round(Number(discountPercent));
    if (!Number.isFinite(value) || value < 0 || value > 100) {
      throw new BadRequestException(
        'discountPercent must be between 0 and 100',
      );
    }
    return value;
  }

  async setAdvertisementTariff(
    placement: CategoryTypeEnum,
    plan: AdvertisementPlanEnum,
    amount: number,
  ): Promise<Record<string, number>> {
    const value = Math.round(Number(amount));
    if (!Number.isFinite(value) || value < 0) {
      throw new BadRequestException('amount must be a non-negative number');
    }
    const key = advertisementTariffKey(placement, plan);
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      { $set: { [`advertisementTariffs.${key}`]: value } },
      { new: true, upsert: true },
    );
    return { ...(updated?.advertisementTariffs ?? {}) };
  }

  async deleteAdvertisementTariff(
    placement: CategoryTypeEnum,
    plan: AdvertisementPlanEnum,
  ): Promise<Record<string, number>> {
    const key = advertisementTariffKey(placement, plan);
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      { $unset: { [`advertisementTariffs.${key}`]: '' } },
      { new: true, upsert: true },
    );
    return { ...(updated?.advertisementTariffs ?? {}) };
  }

  async setAdvertisementTariffs(
    rows: Array<{
      placement: CategoryTypeEnum;
      plan: AdvertisementPlanEnum;
      amount: number;
    }>,
  ): Promise<Record<string, number>> {
    const map: Record<string, number> = {};
    for (const row of rows) {
      const value = Math.round(Number(row.amount));
      if (!Number.isFinite(value) || value < 0) {
        throw new BadRequestException('amount must be a non-negative number');
      }
      map[advertisementTariffKey(row.placement, row.plan)] = value;
    }
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      { $set: { advertisementTariffs: map } },
      { new: true, upsert: true },
    );
    return { ...(updated?.advertisementTariffs ?? {}) };
  }

  async resetAdvertisementTariffs(): Promise<Record<string, number>> {
    await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      { $set: { advertisementTariffs: {} } },
      { upsert: true },
    );
    return {};
  }

  async setPromotionTariff(
    plan: ServicePromotionPlanEnum,
    amount: number,
    days?: number | null,
    discountPercent?: number | null,
  ): Promise<Record<string, number>> {
    const value = Math.round(Number(amount));
    if (!Number.isFinite(value) || value < 0) {
      throw new BadRequestException('amount must be a non-negative number');
    }
    if (!Object.values(ServicePromotionPlanEnum).includes(plan)) {
      throw new BadRequestException('Unknown promotion plan');
    }
    const daysValue = this.assertPromotionDays(days);
    const discountValue = this.assertDiscountPercent(discountPercent);
    const $set: Record<string, number> = {
      [`promotionTariffs.${plan}`]: value,
    };
    const $unset: Record<string, string> = {};
    if (daysValue != null) {
      $set[`promotionTariffDays.${plan}`] = daysValue;
    } else if (days === null) {
      $unset[`promotionTariffDays.${plan}`] = '';
    }
    if (discountValue != null) {
      $set[`promotionTariffDiscounts.${plan}`] = discountValue;
    } else if (discountPercent === null) {
      $unset[`promotionTariffDiscounts.${plan}`] = '';
    }
    const update: Record<string, unknown> = { $set };
    if (Object.keys($unset).length) update.$unset = $unset;
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      update,
      { new: true, upsert: true },
    );
    return { ...(updated?.promotionTariffs ?? {}) };
  }

  async deletePromotionTariff(
    plan: ServicePromotionPlanEnum,
  ): Promise<Record<string, number>> {
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      {
        $unset: {
          [`promotionTariffs.${plan}`]: '',
          [`promotionTariffDays.${plan}`]: '',
          [`promotionTariffDiscounts.${plan}`]: '',
        },
      },
      { new: true, upsert: true },
    );
    return { ...(updated?.promotionTariffs ?? {}) };
  }

  async setPromotionTariffs(
    rows: Array<{
      plan: ServicePromotionPlanEnum;
      amount: number;
      days?: number | null;
      discountPercent?: number | null;
    }>,
  ): Promise<Record<string, number>> {
    const map: Record<string, number> = {};
    const daysMap: Record<string, number> = {};
    const discountMap: Record<string, number> = {};
    for (const row of rows) {
      const value = Math.round(Number(row.amount));
      if (!Number.isFinite(value) || value < 0) {
        throw new BadRequestException('amount must be a non-negative number');
      }
      if (!Object.values(ServicePromotionPlanEnum).includes(row.plan)) {
        throw new BadRequestException('Unknown promotion plan');
      }
      map[row.plan] = value;
      const daysValue = this.assertPromotionDays(row.days);
      if (daysValue != null) daysMap[row.plan] = daysValue;
      const discountValue = this.assertDiscountPercent(row.discountPercent);
      if (discountValue != null && discountValue > 0) {
        discountMap[row.plan] = discountValue;
      }
    }
    const updated = await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      {
        $set: {
          promotionTariffs: map,
          promotionTariffDays: daysMap,
          promotionTariffDiscounts: discountMap,
        },
      },
      { new: true, upsert: true },
    );
    return { ...(updated?.promotionTariffs ?? {}) };
  }

  async resetPromotionTariffs(): Promise<Record<string, number>> {
    await this.settingsModel.findByIdAndUpdate(
      APP_SETTINGS_ID,
      {
        $set: {
          promotionTariffs: {},
          promotionTariffDays: {},
          promotionTariffDiscounts: {},
        },
      },
      { upsert: true },
    );
    return {};
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
