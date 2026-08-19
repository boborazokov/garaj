import { Module } from '@nestjs/common';
import { ItemSchedule } from '../schedule';
import { ItemService } from '../service';

@Module({
  imports: [],
  providers: [ItemService, ItemSchedule],
})
export class ItemModule {}
