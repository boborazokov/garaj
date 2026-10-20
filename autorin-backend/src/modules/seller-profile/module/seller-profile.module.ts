import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { UserModel } from 'src/modules/user/model/user.model';
import { PartModel } from 'src/modules/part/model/part.model';
import { SellerProfileViewModel } from '../model/seller-profile-view.model';
import { SellerProfileResolver } from '../resolver/seller-profile.resolver';
import { SellerProfileService } from '../service/seller-profile.service';
import { PushModule } from 'src/services/push/push.module';

@Module({
  imports: [
    PushModule,
    MongooseModule.forFeature([
      UserModel,
      PartModel,
      { ...SellerProfileViewModel, name: COLLECTIONS.SELLER_PROFILE_VIEWS },
    ]),
  ],
  providers: [SellerProfileService, SellerProfileResolver],
  exports: [SellerProfileService],
})
export class SellerProfileModule {}
