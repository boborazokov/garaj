import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConversationModel } from 'src/modules/conversation/model';
import { ConversationModule } from 'src/modules/conversation/module';
import { PushModule } from 'src/services/push';
import { MessageModel } from '../model';
import { MessageResolver } from '../resolver';
import { AntiSpamService, MessageService } from '../service';

@Module({
  imports: [
    // Both models registered locally: messages own their collection,
    // conversation collection accessed for atomic updates and
    // participant checks during send / setTyping / list.
    MongooseModule.forFeature([MessageModel, ConversationModel]),
    forwardRef(() => ConversationModule),
    PushModule,
  ],
  providers: [MessageResolver, MessageService, AntiSpamService],
  exports: [MessageService],
})
export class MessageModule {}
