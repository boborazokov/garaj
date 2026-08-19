import { ModelDefinition, SchemaFactory } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { DeviceToken } from '../schema';

export const deviceTokenSchema = SchemaFactory.createForClass(DeviceToken);

// Token is the natural primary lookup key when FCM reports invalid tokens
// so the bulk-deactivate update can use it directly.
deviceTokenSchema.index({ token: 1 }, { unique: true });

// Optimized for "give me every active token for these users".
deviceTokenSchema.index({ user: 1, isActive: 1 });

export const DeviceTokenModel: ModelDefinition = {
  name: COLLECTIONS.DEVICE_TOKENS,
  schema: deviceTokenSchema,
};
