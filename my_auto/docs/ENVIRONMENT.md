# Environment configuration

## Flutter (`.env`)

```env
API_URL=https://api.garajmarket.uz
API_File_URL=https://storage.garajmarket.uz
API_GEOCODE_URL=https://nominatim.openstreetmap.org/reverse
MAPTILER_API_KEY=<key>
```

**Local dev example:**

```env
API_URL=http://192.168.0.121:7007
API_File_URL=http://192.168.0.121:9011
```

Never commit production secrets. `.env` is bundled in assets for mobile — use CI secrets for release builds or `--dart-define`.

## Backend (reference)

```env
NODE_ENV=production
PORT=7007
MONGODB_URI=mongodb://user:pass@host:27017/garaj?authSource=admin
REDIS_URL=redis://:pass@host:6379
JWT_ACCESS_SECRET=<32+ random>
JWT_REFRESH_SECRET=<32+ random>
JWT_ACCESS_TTL=15m
JWT_REFRESH_TTL=30d
COOKIE_DOMAIN=.garajmarket.uz
CORS_ORIGINS=https://garajmarket.uz
MINIO_ENDPOINT=
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=
FCM_PROJECT_ID=
SENTRY_DSN=
```

## Firebase

- `google-services.json` (Android)  
- `GoogleService-Info.plist` (iOS)  
- Not committed if contains sensitive keys — use CI injection  

## Stages

| Stage | API_URL | Notes |
|-------|---------|-------|
| local | LAN IP | Physical device must reach host |
| staging | staging-api.* | Short JWT TTL for refresh tests |
| prod | api.garajmarket.uz | HTTPS only |
