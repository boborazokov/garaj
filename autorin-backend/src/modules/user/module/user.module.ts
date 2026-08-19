import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { MinioModule } from 'src/utils/minio';
import { PartModel } from 'src/modules/part/model';
import { WorkshopModel } from 'src/modules/workshop/model';
import { UserResolver } from '../resolver';
import { UserService } from '../service';
import { UserModel } from '../model';

@Module({
  imports: [
    MongooseModule.forFeature([UserModel, PartModel, WorkshopModel]),
    MinioModule,
  ],
  providers: [UserResolver, UserService],
  exports: [UserService],
})
export class UserModule {}
