import { applyDecorators, SetMetadata, UseGuards } from '@nestjs/common';
import { IS_OPTIONAL_AUTH_KEY } from '../constants/auth-metadata.constants';
import { OptionalAuthGuard } from '../guard';

/**
 * Handler-level: guest browse + optional Bearer for personalization.
 * Also applies {@link OptionalAuthGuard} (redundant with global guard but keeps intent explicit).
 */
export function UseOptionalAuth(): MethodDecorator {
  return applyDecorators(
    SetMetadata(IS_OPTIONAL_AUTH_KEY, true),
    UseGuards(OptionalAuthGuard),
  );
}

/**
 * Resolver/class-level: marks every query/mutation on this class as optional-auth.
 * Use when the entire resolver is a public feed (recommendation, search, …).
 */
export function OptionalAuthResolver(): ClassDecorator {
  return SetMetadata(IS_OPTIONAL_AUTH_KEY, true);
}
