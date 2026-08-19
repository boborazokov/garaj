import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConversationModel } from '../model';
import { ConversationResolver } from '../resolver';
import { ConversationService } from '../service';
import { MessageModule } from 'src/modules/message/module';
import { MessageModel } from 'src/modules/message/model';

/**
 * Conversation depends on Message for the dual-update in `markAsRead`.
 * We use `forwardRef` because Message also depends on Conversation
 * (service.assertParticipant). Mongoose registration of MessageModel
 * here ensures `markAsRead` has access to the model collection.
 */
@Module({
  imports: [
    MongooseModule.forFeature([ConversationModel, MessageModel]),
    forwardRef(() => MessageModule),
  ],
  providers: [ConversationResolver, ConversationService],
  exports: [ConversationService, MongooseModule],
})
export class ConversationModule {}
