import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { TrendingService } from '../service/trending.service';

@Injectable()
export class TrendingSchedule {
  private readonly logger = new Logger(TrendingSchedule.name);

  constructor(private readonly trendingService: TrendingService) {}

  @Cron('*/15 * * * *')
  async recalculateTrending() {
    try {
      await this.trendingService.recalculateTrending();
    } catch (err) {
      this.logger.error(`Trending cron failed: ${err}`);
    }
  }
}
