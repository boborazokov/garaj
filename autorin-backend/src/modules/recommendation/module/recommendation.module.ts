import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ActivityModule } from 'src/modules/activity/module/activity.module';
import { ConversationModel } from 'src/modules/conversation/model';
import { FavoriteModel } from 'src/modules/favorite/model';
import { OrderModel } from 'src/modules/order/model';
import { PartModel } from 'src/modules/part/model';
import { TrendingModule } from 'src/modules/trending/module/trending.module';
import { RecommendationResolver } from '../resolver/recommendation.resolver';
import { RecommendationScoringService } from '../service/recommendation-scoring.service';
import { RecommendationService } from '../service/recommendation.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      PartModel,
      OrderModel,
      FavoriteModel,
      ConversationModel,
    ]),
    ActivityModule,
    TrendingModule,
  ],
  providers: [
    RecommendationScoringService,
    RecommendationService,
    RecommendationResolver,
  ],
  exports: [RecommendationService],
})
export class RecommendationModule {}
