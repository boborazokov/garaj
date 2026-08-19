import {
  Controller,
  Get,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Public } from 'src/auth/decorators';
import { isDebugRouteAllowed } from 'src/configs/bootstrap';
import { FirebaseService } from './firebase.service';

/**
 * Lightweight ops check for FCM readiness.
 * Disabled in production unless `ALLOW_FIREBASE_DEBUG_ENDPOINT=true`.
 */
@Controller('debug')
export class FirebaseDebugController {
  constructor(
    private readonly firebase: FirebaseService,
    private readonly config: ConfigService,
  ) {}

  @Public()
  @Get('firebase')
  firebaseSnapshot() {
    if (!isDebugRouteAllowed(this.config)) {
      throw new NotFoundException();
    }
    return this.firebase.getDebugSnapshot();
  }
}
