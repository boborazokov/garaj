import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ViewModel } from '../model';
import { ViewResolver } from '../resolver/view.resolver';
import { ViewService } from '../service';

@Module({
  imports: [MongooseModule.forFeature([ViewModel])],
  providers: [ViewService, ViewResolver],
  exports: [ViewService],
})
export class ViewModule {}
