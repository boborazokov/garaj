import { applyDecorators, UseGuards } from '@nestjs/common';
import { AuthGuard } from '../guard';

/** Explicit strict JWT (redundant with global guard; kept for readability). */
export function UseAuth(): MethodDecorator {
  return applyDecorators(UseGuards(AuthGuard));
}
