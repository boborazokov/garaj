# Deployment

## Flutter mobile

```bash
flutter pub get
flutter gen-l10n   # or intl_utils:generate
flutter build apk --release
flutter build ios --release
```

Release checklist:

- [ ] `.env` points to production API (HTTPS)  
- [ ] Firebase prod project configured  
- [ ] ProGuard/R8 rules for release Android  
- [ ] No `debugPrint` of tokens/OTP  
- [ ] Version bump in `pubspec.yaml`  

## Backend (NestJS — separate repo)

```bash
npm ci
npm run build
npm run start:prod
```

Docker (reference):

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
CMD ["node", "dist/main.js"]
```

## Infrastructure

- TLS termination at reverse proxy (nginx / cloud LB)  
- MongoDB replica set  
- Redis for WS limits + OTP rate limits  
- Object storage (MinIO/S3) private bucket, signed URLs for reads  

## Rollback

- Mobile: staged rollout in Play Console / TestFlight  
- API: blue/green or previous container image; **do not** break refresh token schema without migration  

## Monitoring

- Health: `GET /health`  
- Sentry release tags matching app version  
- Alert on auth failure rate spike (>5% of logins)
