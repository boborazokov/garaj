import { Module } from '@nestjs/common';
import { AuthResolver } from '../resolver';
import { AuthService } from '../service';
import { OtpProtectionService } from '../otp/otp-protection.service';
import { MongooseModule } from '@nestjs/mongoose';
import { UserModel } from 'src/modules/user/model';
import { SmsModule } from 'src/utils/sms';

@Module({
  imports: [MongooseModule.forFeature([UserModel]), SmsModule],
  providers: [AuthResolver, AuthService, OtpProtectionService],
  exports: [AuthService],
})
export class AuthModule {}
