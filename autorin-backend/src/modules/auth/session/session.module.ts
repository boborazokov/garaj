import { Global, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AuthSessionModel } from '../model/auth-session.model';
import { SessionService } from './session.service';

@Global()
@Module({
  imports: [MongooseModule.forFeature([AuthSessionModel])],
  providers: [SessionService],
  exports: [SessionService],
})
export class SessionModule {}
