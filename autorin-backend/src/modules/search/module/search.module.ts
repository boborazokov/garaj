import { Module, OnModuleInit } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ActivityModule } from 'src/modules/activity/module/activity.module';
import { PartModel } from 'src/modules/part/model';
import { SearchResolver } from '../resolver/search.resolver';
import { PartIndexService } from '../service/part-index.service';
import { SearchService } from '../service/search.service';

@Module({
  imports: [
    MongooseModule.forFeature([PartModel]),
    ActivityModule,
  ],
  providers: [PartIndexService, SearchService, SearchResolver],
  exports: [PartIndexService, SearchService],
})
export class SearchModule implements OnModuleInit {
  constructor(private readonly partIndex: PartIndexService) {}

  onModuleInit() {
    void this.partIndex.reindexAllActive();
  }
}
