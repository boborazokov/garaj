import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { ContextType } from 'src/auth/interfaces';
import { COLLECTIONS } from 'src/constants';
import { POPULATIONS } from 'src/constants/populations.constants';
import { ActivityTypeEnum } from 'src/modules/activity/enums';
import { ActivityService } from 'src/modules/activity/service/activity.service';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { Part } from 'src/modules/part/schema';
import { MeilisearchService } from 'src/services/meilisearch';
import { SearchProductsArgs } from '../dto/search-products.args';
import { SearchProductsResult } from '../types/search-products-result.type';

@Injectable()
export class SearchService {
  constructor(
    private readonly meili: MeilisearchService,
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    private readonly activityService: ActivityService,
  ) {}

  async searchProducts(
    args: SearchProductsArgs,
    context: ContextType,
  ): Promise<SearchProductsResult> {
    const limit = Math.min(args.limit ?? 20, 50);
    const offset = args.offset ?? 0;

    const filters: string[] = [`status = "${ItemStatusEnum.ACTIVE}"`];

    if (args.category) {
      filters.push(`categoryId = "${args.category}"`);
    }
    if (args.city) {
      filters.push(`city = "${args.city}"`);
    }
    if (args.minPrice != null) {
      filters.push(`price >= ${args.minPrice}`);
    }
    if (args.maxPrice != null) {
      filters.push(`price <= ${args.maxPrice}`);
    }

    const result = await this.meili.searchParts({
      query: args.query,
      filter: filters,
      sort: ['promotedUntil:desc', 'createdAt:desc'],
      limit,
      offset,
    });

    const ids = result.hits.map((h) => h.id);
    if (!ids.length) {
      return {
        payload: [],
        total: result.estimatedTotalHits ?? 0,
        limit,
        offset,
        processingTimeMs: result.processingTimeMs,
      };
    }

    const parts = await this.partModel
      .find({ _id: { $in: ids.map((id) => new Types.ObjectId(id)) } })
      .populate([...POPULATIONS.part, ...POPULATIONS.item, 'brand', 'carModel'])
      .lean();

    const orderMap = new Map<string, number>(
      ids.map((id, i) => [id, i]),
    );
    const sorted = [...parts].sort((a, b) => {
      const ai = orderMap.get(String(a._id)) ?? 0;
      const bi = orderMap.get(String(b._id)) ?? 0;
      return ai - bi;
    });

    if (context.userId && args.query?.trim()) {
      void this.activityService.track({
        userId: context.userId,
        type: ActivityTypeEnum.SEARCH_QUERY,
        metadata: { query: args.query.trim() },
      });
    }

    return {
      payload: sorted as Part[],
      total: result.estimatedTotalHits ?? sorted.length,
      limit,
      offset,
      processingTimeMs: result.processingTimeMs,
    };
  }
}
