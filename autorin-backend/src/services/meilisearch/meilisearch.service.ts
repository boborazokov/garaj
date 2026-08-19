import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';
import {
  MEILI_FILTERABLE,
  MEILI_PARTS_INDEX,
  MEILI_SEARCHABLE,
  MEILI_SORTABLE,
} from './meilisearch.constants';

export type MeiliPartDocument = {
  id: string;
  title: string;
  description: string;
  brandId?: string;
  brandName?: string;
  modelId?: string;
  modelName?: string;
  categoryId: string;
  categoryName?: string;
  city?: string;
  price: number;
  currency: string;
  tags: string[];
  sellerId: string;
  status: string;
  isPromoted: boolean;
  createdAt: number;
  promotedUntil?: number;
};

type MeiliSearchResponse = {
  hits: MeiliPartDocument[];
  estimatedTotalHits?: number;
  processingTimeMs: number;
};

@Injectable()
export class MeilisearchService implements OnModuleInit {
  private readonly logger = new Logger(MeilisearchService.name);
  private readonly http: AxiosInstance;
  private readonly indexUid = MEILI_PARTS_INDEX;

  constructor(private readonly config: ConfigService) {
    const host =
      this.config.get<string>('MEILI_HOST') ?? 'http://localhost:7700';
    const apiKey =
      this.config.get<string>('MEILI_MASTER_KEY') ?? 'autorin_master_key';

    this.http = axios.create({
      baseURL: host,
      headers: { Authorization: `Bearer ${apiKey}` },
      timeout: 10_000,
    });
  }

  async onModuleInit() {
    try {
      await this.ensurePartsIndex();
    } catch (err) {
      this.logger.warn(
        `Meilisearch unavailable at startup — search will retry on demand: ${err}`,
      );
    }
  }

  private indexPath(suffix = '') {
    return `/indexes/${this.indexUid}${suffix}`;
  }

  async ensurePartsIndex() {
    try {
      await this.http.get(this.indexPath());
    } catch {
      await this.http.post('/indexes', {
        uid: this.indexUid,
        primaryKey: 'id',
      });
    }

    // Meilisearch v1+: apply index settings in one PATCH (subroutes vary by version).
    await this.http.patch(this.indexPath('/settings'), {
      searchableAttributes: MEILI_SEARCHABLE,
      filterableAttributes: MEILI_FILTERABLE,
      sortableAttributes: MEILI_SORTABLE,
      typoTolerance: { enabled: true },
    });
  }

  async upsertPart(doc: MeiliPartDocument) {
    await this.ensurePartsIndex();
    await this.http.post(this.indexPath('/documents'), [doc]);
  }

  async deletePart(partId: string) {
    try {
      await this.http.delete(this.indexPath(`/documents/${partId}`));
    } catch {
      /* index may not exist */
    }
  }

  async searchParts(params: {
    query?: string;
    filter?: string[];
    sort?: string[];
    limit: number;
    offset: number;
  }): Promise<MeiliSearchResponse> {
    await this.ensurePartsIndex();
    const { data } = await this.http.post<MeiliSearchResponse>(
      this.indexPath('/search'),
      {
        q: params.query ?? '',
        filter: params.filter?.length ? params.filter.join(' AND ') : undefined,
        sort: params.sort,
        limit: params.limit,
        offset: params.offset,
      },
    );
    return data;
  }
}
