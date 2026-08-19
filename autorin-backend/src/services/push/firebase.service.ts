import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as fs from 'fs';
import * as path from 'path';
import * as admin from 'firebase-admin';

/** Parsed Admin SDK JSON (snake_case as in GCP download). */
type ServiceAccountFile = {
  type?: string;
  project_id?: string;
  private_key?: string;
  client_email?: string;
};

/**
 * Thin, opinionated wrapper around `firebase-admin` Messaging.
 *
 * Credential priority (first match wins):
 *  1. FIREBASE_SERVICE_ACCOUNT_PATH
 *  2. GOOGLE_APPLICATION_CREDENTIALS
 *  3. FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY
 *
 * Paths: absolute (Windows/Linux) or relative (`./`, `../`, resolved from `process.cwd()`).
 */
@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);

  private static readonly fileParseLogger = new Logger(FirebaseService.name);

  /** Default Nest app singleton; null when push is disabled by config. */
  private app: admin.app.App | null = null;

  /** Known project id after successful init (survives for debug / hot reload heuristics). */
  private initializedProjectId: string | null = null;

  constructor(private readonly config: ConfigService) {}

  onModuleInit(): void {
    try {
      this.bootstrapFirebase();
    } catch (e) {
      this.logger.error((e as Error).stack ?? (e as Error).message);
      this.app = null;
    }
  }

  private bootstrapFirebase(): void {
    if (admin.apps.length) {
      this.app = admin.app();
      if (!this.initializedProjectId) {
        this.initializedProjectId =
          this.config.get<string>('FIREBASE_PROJECT_ID')?.trim() || null;
      }
      this.logger.log(
        `Firebase Admin reusing existing SDK app (${admin.apps.length} app(s)); project=${this.initializedProjectId ?? '?'}`,
      );
      return;
    }

    const rawPath1 =
      this.config.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH') ?? '';
    const rawPath2 =
      this.config.get<string>('GOOGLE_APPLICATION_CREDENTIALS') ?? '';

    // Priority (1): explicit service account path
    if (rawPath1.trim()) {
      this.tryInitFromFile(rawPath1.trim(), 'FIREBASE_SERVICE_ACCOUNT_PATH');
      if (this.app) return;
    }

    // Priority (2): standard Google env var
    if (rawPath2.trim()) {
      this.tryInitFromFile(
        rawPath2.trim(),
        'GOOGLE_APPLICATION_CREDENTIALS',
      );
      if (this.app) return;
    }

    // Priority (3): inline env PEM
    this.tryInitFromEnvVariables();
  }

  private tryInitFromFile(
    configuredRaw: string,
    envVarName: string,
  ): void {
    const resolved = FirebaseService.resolveCredentialsPath(configuredRaw);
    const cwd = process.cwd();
    const exists = fs.existsSync(resolved);

    this.logFirebaseBootDiagnostics(envVarName, cwd, configuredRaw, resolved, exists);

    if (!exists) return;

    let rawJson: string;
    try {
      rawJson = fs.readFileSync(resolved, 'utf8');
    } catch (e) {
      const err = e as Error;
      this.logger.error(
        `[FirebaseService] Failed to read credential file "${resolved}": ${err.stack ?? err.message}`,
      );
      return;
    }

    const sa = FirebaseService.validateServiceAccountJson(rawJson);
    if (!sa) return;

    const privateKeyNormalized = FirebaseService.normalizePrivateKey(
      sa.private_key!,
    );

    try {
      this.app = admin.initializeApp({
        credential: admin.credential.cert({
          projectId: sa.project_id as string,
          clientEmail: sa.client_email as string,
          privateKey: privateKeyNormalized,
        }),
      });
      this.initializedProjectId = sa.project_id!;
      this.logger.log(
        `Firebase Admin initialized from JSON (project=${this.initializedProjectId})`,
      );
    } catch (e) {
      const err = e as Error;
      this.logger.error(
        `[FirebaseService] initializeApp(from JSON) failed: ${err.stack ?? err.message}`,
      );
      this.app = null;
    }
  }

  private tryInitFromEnvVariables(): void {
    const projectId = this.config.get<string>('FIREBASE_PROJECT_ID');
    const clientEmail = this.config.get<string>('FIREBASE_CLIENT_EMAIL');
    const privateKey = FirebaseService.normalizePrivateKey(
      (this.config.get<string>('FIREBASE_PRIVATE_KEY') ?? '').trim(),
    );

    this.logFirebaseBootDiagnostics(
      'FIREBASE_PROJECT_ID+FIREBASE_CLIENT_EMAIL+FIREBASE_PRIVATE_KEY',
      process.cwd(),
      '(env inline)',
      '(n/a)',
      !!(projectId && clientEmail && privateKey),
    );

    if (!projectId || !clientEmail || !privateKey) {
      this.logger.warn(
        'Firebase credentials missing. Push notifications will be DISABLED. ' +
          'Set FIREBASE_SERVICE_ACCOUNT_PATH, or GOOGLE_APPLICATION_CREDENTIALS, ' +
          'or FIREBASE_PROJECT_ID + FIREBASE_CLIENT_EMAIL + FIREBASE_PRIVATE_KEY.',
      );
      return;
    }

    try {
      this.app = admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          privateKey,
        }),
      });
      this.initializedProjectId = projectId;
      this.logger.log(
        `Firebase Admin initialized from env (project=${projectId})`,
      );
    } catch (e) {
      const err = e as Error;
      this.logger.error(
        `[FirebaseService] initializeApp(from env vars) failed: ${err.stack ?? err.message}`,
      );
      this.app = null;
    }
  }

  /**
   * Resolves `./`, `../`, or absolute paths (Windows and POSIX).
   */
  static resolveCredentialsPath(raw: string): string {
    const trimmed = raw.trim().replace(/^["']+|["']+$/g, '');
    return path.isAbsolute(trimmed)
      ? path.normalize(trimmed)
      : path.resolve(process.cwd(), trimmed);
  }

  static normalizePrivateKey(key: string): string {
    return key.replace(/\\n/g, '\n');
  }

  /** Safe parse + field validation for service account JSON. */
  static validateServiceAccountJson(rawJson: string): ServiceAccountFile | null {
    let parsed: unknown;
    try {
      parsed = JSON.parse(rawJson);
    } catch (e) {
      const err = e as Error;
      FirebaseService.fileParseLogger.warn(
        `Invalid JSON in credential file: ${err.message}`,
      );
      return null;
    }

    const sa = parsed as ServiceAccountFile;
    const projectId =
      typeof sa.project_id === 'string' ? sa.project_id.trim() : '';
    const clientEmail =
      typeof sa.client_email === 'string' ? sa.client_email.trim() : '';
    const privateKey =
      typeof sa.private_key === 'string' ? sa.private_key.trim() : '';

    if (!projectId || !clientEmail || !privateKey) {
      FirebaseService.fileParseLogger.warn(
        'Credential JSON must include non-empty project_id, client_email, private_key.',
      );
      return null;
    }

    return { ...sa, project_id: projectId, client_email: clientEmail, private_key: privateKey };
  }

  private logFirebaseBootDiagnostics(
    sourceLabel: string,
    cwd: string,
    configured: string,
    resolvedPath: string,
    existsOrPresent: boolean,
  ): void {
    this.logger.log(`cwd=${cwd}`);
    this.logger.log(`serviceAccountEnv=${sourceLabel}`);
    this.logger.log(`configuredValue=${configured}`);
    this.logger.log(`resolvedPath=${resolvedPath}`);
    this.logger.log(`exists=${existsOrPresent}`);
  }

  /** BullMQ worker and HTTP layer share this Nest DI singleton. */
  isReady(): boolean {
    return this.app !== null;
  }

  /** For GET /debug/firebase — no secrets. */
  getDebugSnapshot(): FirebaseDebugPayload {
    return {
      initialized: this.app !== null,
      projectId: this.initializedProjectId,
      appCount: admin.apps.length,
    };
  }

  async sendMulticast(
    tokens: string[],
    message: Omit<admin.messaging.MulticastMessage, 'tokens'>,
  ): Promise<string[]> {
    if (!this.app) {
      this.logger.debug(
        `[noop push] tokens=${tokens.length} title="${message.notification?.title ?? ''}"`,
      );
      return [];
    }
    if (!tokens.length) return [];

    const invalid: string[] = [];
    const chunks = this.chunk(tokens, 500);
    for (const chunk of chunks) {
      try {
        const res = await this.app
          .messaging()
          .sendEachForMulticast({ ...message, tokens: chunk });
        res.responses.forEach((r, i) => {
          if (r.success) return;
          const code = r.error?.code ?? '';
          if (
            code === 'messaging/invalid-registration-token' ||
            code === 'messaging/registration-token-not-registered' ||
            code === 'messaging/invalid-argument'
          ) {
            invalid.push(chunk[i]);
          } else {
            this.logger.warn(
              `FCM transient failure for token #${i} in chunk: ${code} ${r.error?.message ?? ''}`,
            );
          }
        });
      } catch (e) {
        this.logger.error(
          `[FirebaseService] FCM multicast failure: ${(e as Error).stack ?? (e as Error).message}`,
        );
        throw e;
      }
    }

    return invalid;
  }

  private chunk<T>(arr: T[], size: number): T[][] {
    const out: T[][] = [];
    for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
    return out;
  }
}

export type FirebaseDebugPayload = {
  initialized: boolean;
  projectId: string | null;
  appCount: number;
};
