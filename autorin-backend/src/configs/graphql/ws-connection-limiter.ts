import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Types } from 'mongoose';
import { UserRoleEnum } from 'src/modules/user/enums';
import { AuthTokenPayload } from 'src/auth/interfaces';

const wsLogger = new Logger('GraphQL-WS');

/**
 * Limits concurrent graphql-ws connections and handshake frequency per user
 * to reduce reconnect spam / subscription abuse.
 */
@Injectable()
export class WsConnectionLimiter {
  private readonly connections = new Map<string, Set<string>>();
  /** Sliding window history of handshake timestamps per user. */
  private readonly handshakeHistory = new Map<string, number[]>();

  constructor(private readonly config: ConfigService) {}

  private maxPerUser(): number {
    return Number(this.config.get('WS_MAX_CONNECTIONS_PER_USER') ?? 10);
  }

  private handshakeWindowMs(): number {
    return Number(this.config.get('WS_HANDSHAKE_WINDOW_MS') ?? 10_000);
  }

  private maxHandshakesPerWindow(): number {
    return Number(this.config.get('WS_HANDSHAKE_MAX_PER_WINDOW') ?? 20);
  }

  register(userId: Types.ObjectId, socketId: string): void {
    const key = userId.toString();
    const set = this.connections.get(key) ?? new Set();
    if (set.size >= this.maxPerUser()) {
      wsLogger.warn(`WS connection limit exceeded for user=${key}`);
      throw new Error('TOO_MANY_CONNECTIONS');
    }
    set.add(socketId);
    this.connections.set(key, set);
  }

  unregister(userId: Types.ObjectId | undefined, socketId: string): void {
    if (!userId) return;
    const key = userId.toString();
    const set = this.connections.get(key);
    if (!set) return;
    set.delete(socketId);
    if (set.size === 0) {
      this.connections.delete(key);
      this.handshakeHistory.delete(key);
    }
  }

  /**
   * Allow up to N handshakes per sliding window per user. Tolerant of
   * legitimate reconnect bursts (network change, app resume, hot reload)
   * while still blocking abuse.
   */
  assertHandshakeAllowed(userId: Types.ObjectId): void {
    const key = userId.toString();
    const now = Date.now();
    const windowMs = this.handshakeWindowMs();
    const max = this.maxHandshakesPerWindow();

    const history = (this.handshakeHistory.get(key) ?? []).filter(
      (t) => now - t < windowMs,
    );
    if (history.length >= max) {
      wsLogger.warn(
        `WS handshake throttled for user=${key} (${history.length}/${max} in ${windowMs}ms)`,
      );
      throw new Error('HANDSHAKE_RATE_LIMITED');
    }
    history.push(now);
    this.handshakeHistory.set(key, history);
  }

  /** Called from graphql.config onDisconnect — cleanup tracking for this socket. */
  releaseFromContext(ctx: {
    extra?: { userId?: Types.ObjectId; socketId?: string };
  }): void {
    const uid = ctx?.extra?.userId;
    const sid = ctx?.extra?.socketId;
    if (uid && sid) {
      this.unregister(uid, sid);
    }
  }

  attachSocketId(ctx: { extra?: Record<string, unknown> }): string {
    const socketId = `ws-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
    if (!ctx.extra) ctx.extra = {};
    ctx.extra.socketId = socketId;
    return socketId;
  }
}

export type WsIdentity = {
  userId: Types.ObjectId;
  userRole: UserRoleEnum;
  sid?: string;
};

export function verifyWsToken(
  raw: string | undefined,
  jwtSecret: string,
  jwt: typeof import('jsonwebtoken'),
): WsIdentity {
  if (!raw) throw new Error('UNAUTHENTICATED');
  const [type, token] = raw.split(' ');
  const jwtToken = type === 'Bearer' ? token : raw;
  if (!jwtToken) throw new Error('UNAUTHENTICATED');

  let payload: AuthTokenPayload;
  try {
    const decoded = jwt.verify(jwtToken, jwtSecret) as unknown;
    if (!decoded || typeof decoded === 'string') {
      throw new Error('UNAUTHENTICATED');
    }
    payload = decoded as AuthTokenPayload;
  } catch (e) {
    if (e instanceof jwt.TokenExpiredError) {
      throw new Error('UNAUTHENTICATED');
    }
    wsLogger.warn(
      `WS handshake rejected: ${(e as Error).message || 'jwt verify failed'}`,
    );
    throw new Error('UNAUTHENTICATED');
  }

  if (
    !payload.userId ||
    !Types.ObjectId.isValid(payload.userId) ||
    !payload.userRole ||
    !UserRoleEnum[payload.userRole]
  ) {
    throw new Error('UNAUTHENTICATED');
  }

  return {
    userId: new Types.ObjectId(payload.userId),
    userRole: payload.userRole,
    sid: payload.sid,
  };
}

export function assertWsOriginAllowed(
  origin: string | undefined,
  allowedOrigins: string[],
  isProd: boolean,
): void {
  if (!origin) return;
  if (!isProd && allowedOrigins.length === 0) return;
  if (!allowedOrigins.includes(origin)) {
    wsLogger.warn(`WS handshake rejected: origin=${origin}`);
    throw new Error('ORIGIN_NOT_ALLOWED');
  }
}
