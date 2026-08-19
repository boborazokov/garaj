import { SetMetadata } from '@nestjs/common';
import { IS_PUBLIC_KEY } from '../constants/auth-metadata.constants';

/**
 * Opt-out of global JWT protection for this handler (sign-in, sign-up, etc.).
 * Prefer explicit {@link Public} over forgetting auth on new endpoints.
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
