import { Module } from '@nestjs/common';
import { AuthResolver } from '../resolver';
import { AuthService } from '../service';
import { MongooseModule } from '@nestjs/mongoose';
import { UserModel } from 'src/modules/user/model';
import { SmsModule } from 'src/utils/sms';

@Module({
  imports: [MongooseModule.forFeature([UserModel]), SmsModule],
  providers: [AuthResolver, AuthService],
  exports: [AuthService],
})
export class AuthModule {}
