# AutoRin Web

Веб-версия маркетплейса AutoRin (React + TypeScript + Vite + Apollo GraphQL).

## Структура

| Раздел | URL | Доступ |
|--------|-----|--------|
| Публичный сайт | `/` | Все |
| Админ-панель | `/admin` | `ADMIN` |
| Модерация | `/moderator` | `MODERATOR`, `ADMIN` |

## Запуск

```bash
cd D:\flutter_projects\autorin-web
cp .env.example .env   # укажите VITE_API_URL и VITE_FILE_URL
npm install
npm run dev
```

Backend: `D:\flutter_projects\autorin-backend` (GraphQL `/api`, порт 7007).

## Модерация товаров

1. В MongoDB назначьте пользователю роль `ADMIN` (или через Telegram-бот бэкенда).
2. Войдите на сайт → **Админ** → **Настройки** → включите «Модерация товаров».
3. Назначьте другому пользователю роль `MODERATOR` в **Пользователи**.
4. Новые `createPart` из приложения попадут в очередь `/moderator` до одобрения.

Если модерация выключена — товары сразу `ACTIVE`, как в мобильном приложении.
