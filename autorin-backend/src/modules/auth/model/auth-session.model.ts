import { ModelDefinition } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { AuthSessionSchema } from '../schema/auth-session.schema';

export const AuthSessionModel: ModelDefinition = {
  name: COLLECTIONS.AUTH_SESSIONS,
  schema: AuthSessionSchema,
};
