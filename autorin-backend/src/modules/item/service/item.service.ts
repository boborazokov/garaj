import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { Part } from 'src/modules/part/schema';
import { ItemStatusEnum } from '../enums';

@Injectable()
export class ItemService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
  ) {}

  async archiveOldParts(oneMonthAgo: Date) {
    await this.partModel.updateMany(
      { status: ItemStatusEnum.ACTIVE, createdAt: { $lte: oneMonthAgo } },
      { $set: { status: ItemStatusEnum.ARCHIVED, archivedAt: new Date() } },
    );
  }

  async archiveOldItems() {
    const oneMonthAgo = new Date();
    oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);

    await this.archiveOldParts(oneMonthAgo);
  }
}
