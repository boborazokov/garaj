import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { RecommendationModule } from 'src/modules/recommendation/module/recommendation.module';
import { SearchModule } from 'src/modules/search/module/search.module';
import { MinioModule } from 'src/utils/minio';
import { ViewModule } from 'src/modules/view/module';
import { AppSettingsModule } from 'src/modules/app-settings/module/app-settings.module';
import { FavoriteModel } from 'src/modules/favorite/model';
import { PartModel } from '../model';
import { PartFieldsResolver, PartResolver } from '../resolver';
import { PartService } from '../service';

@Module({
  imports: [
    AppSettingsModule,
    MongooseModule.forFeature([PartModel, FavoriteModel]),
    MinioModule,
    ViewModule,
    SearchModule,
    forwardRef(() => RecommendationModule),
  ],
  providers: [PartResolver, PartFieldsResolver, PartService],
  exports: [PartService],
})
export class PartModule {}
