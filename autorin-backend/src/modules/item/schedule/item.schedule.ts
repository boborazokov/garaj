import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { ItemService } from '../service';

@Injectable()
export class ItemSchedule {
  constructor(private readonly itemService: ItemService) {}

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async archiveOldItems() {
    await this.itemService.archiveOldItems();
  }
}
