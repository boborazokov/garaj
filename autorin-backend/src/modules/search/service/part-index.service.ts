import { Injectable, Logger } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { POPULATIONS } from 'src/constants/populations.constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Part } from 'src/modules/part/schema';
import {
  MeiliPartDocument,
  MeilisearchService,
} from 'src/services/meilisearch';

@Injectable()
export class PartIndexService {
  private readonly logger = new Logger(PartIndexService.name);

  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    private readonly meili: MeilisearchService,
  ) {}

  partToDocument(part: Part & Record<string, unknown>): MeiliPartDocument {
    const category = part.category as { _id?: Types.ObjectId; name?: string };
    const brand = part.brand as { _id?: Types.ObjectId; name?: string } | null;
    const carModel = part.carModel as
      | { _id?: Types.ObjectId; name?: string }
      | null;
    const seller = part.seller as { _id?: Types.ObjectId };

    const tags: string[] = [];
    if (part.isNew) tags.push('new');
    if (part.isNegotiable) tags.push('negotiable');
    if (part.isPromoted) tags.push('promoted');
    if (category?.name) tags.push(category.name);

    return {
      id: part._id.toString(),
      title: part.name,
      description: part.description ?? '',
      brandId: brand?._id?.toString(),
      brandName: brand?.name,
      modelId: carModel?._id?.toString(),
      modelName: carModel?.name,
      categoryId: category?._id?.toString() ?? '',
      categoryName: category?.name,
      city: part.region ?? part.location ?? '',
      price: part.price ?? 0,
      currency: part.currency,
      tags,
      sellerId: seller?._id?.toString() ?? part.seller?.toString() ?? '',
      status: part.status,
      isPromoted: part.isPromoted === true,
      createdAt: new Date(part.createdAt).getTime(),
      promotedUntil: part.promotedUntil
        ? new Date(part.promotedUntil).getTime()
        : undefined,
    };
  }

  async indexPartById(partId: Types.ObjectId | string) {
    const part = await this.partModel
      .findById(partId)
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .lean();

    if (!part || part.status !== ItemStatusEnum.ACTIVE) {
      await this.meili.deletePart(partId.toString());
      return;
    }

    await this.meili.upsertPart(
      this.partToDocument(part as unknown as Part & Record<string, unknown>),
    );
  }

  async removePart(partId: Types.ObjectId | string) {
    await this.meili.deletePart(partId.toString());
  }

  async reindexAllActive() {
    const cursor = this.partModel
      .find({ status: ItemStatusEnum.ACTIVE })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .cursor();

    let count = 0;
    for await (const part of cursor) {
      try {
        await this.meili.upsertPart(
          this.partToDocument(part as unknown as Part & Record<string, unknown>),
        );
        count++;
      } catch (err) {
        this.logger.warn(`Failed to index part ${part._id}: ${err}`);
      }
    }
    this.logger.log(`Reindexed ${count} active parts into Meilisearch`);
  }
}
