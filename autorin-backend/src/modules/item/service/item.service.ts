import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { AppSettingsService } from 'src/modules/app-settings/service/app-settings.service';
import { Part } from 'src/modules/part/schema';
import { ItemStatusEnum } from '../enums';

@Injectable()
export class ItemService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    private readonly appSettingsService: AppSettingsService,
  ) {}

  async archiveOldParts(oneMonthAgo: Date) {
    await this.partModel.updateMany(
      { status: ItemStatusEnum.ACTIVE, createdAt: { $lte: oneMonthAgo } },
      { $set: { status: ItemStatusEnum.ARCHIVED, archivedAt: new Date() } },
    );
  }

  async archiveOldItems() {
    if (!(await this.appSettingsService.isProductModerationEnabled())) return;

    const oneMonthAgo = new Date();
    oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);

    await this.archiveOldParts(oneMonthAgo);
  }
}
