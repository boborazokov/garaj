import { Field, InputType, Int } from '@nestjs/graphql';
import {
  ArrayMaxSize,
  IsInt,
  IsOptional,
  Max,
  MaxLength,
  Min,
  ValidateIf,
} from 'class-validator';
import { Types } from 'mongoose';
import { ObjectIdScalar } from 'src/common';
import {
  MESSAGE_IMAGES_MAX,
  MESSAGE_TEXT_MAX,
  MESSAGE_VOICE_MAX_DURATION_MS,
} from '../../schema/message.schema';

@InputType()
export class SendMessageInput {
  @Field(() => ObjectIdScalar)
  conversationId: Types.ObjectId;

  /**
   * Either `text`, at least one image, or a voice message must be
   * provided. The service enforces non-emptiness explicitly.
   */
  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(MESSAGE_TEXT_MAX)
  text?: string;

  @Field(() => [String], { nullable: true })
  @IsOptional()
  @ArrayMaxSize(MESSAGE_IMAGES_MAX)
  @ValidateIf((_, value: string[] | undefined) => Array.isArray(value))
  images?: string[];

  /** Message id we're replying to (must belong to the same conversation). */
  @Field(() => ObjectIdScalar, { nullable: true })
  @IsOptional()
  replyTo?: Types.ObjectId;

  /** Public URL of a previously-uploaded voice file. */
  @Field({ nullable: true })
  @IsOptional()
  @MaxLength(1024)
  voiceUrl?: string;

  @Field(() => Int, { nullable: true })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(MESSAGE_VOICE_MAX_DURATION_MS)
  voiceDurationMs?: number;
}
