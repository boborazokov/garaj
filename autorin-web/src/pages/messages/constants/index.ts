import type { LocalizedText } from "@/lib/i18n";

export const CONVERSATIONS_POLL_MS = 8_000;
export const MESSAGES_POLL_MS = 4_000;
export const PINNED_STORAGE_KEY = "autorin.admin.messages.pinned";
/** When API has no conversations, show auto-parts demo threads. */
export const USE_MOCK_MESSAGES_FALLBACK = true;

export const MESSAGES_COLORS = {
  accent: "#226DF7",
  accentSoft: "rgba(34, 109, 247, 0.08)",
  accentBorder: "rgba(34, 109, 247, 0.35)",
  border: "#e2e8f0",
  muted: "#64748b",
  text: "#0f172a",
  textSecondary: "#475569",
  unreadBadge: "#ef4444",
  searchBg: "#f8fafc",
  bubbleIncoming: "#ffffff",
  bubbleOutgoing: "#226DF7",
} as const;

export const MESSAGES_TEXTS = {
  title: { uz: "Xabarlar", ru: "Сообщения", en: "Messages" },
  searchPlaceholder: {
    uz: "Xabarlarni qidirish",
    ru: "Поиск сообщений",
    en: "Search Messages",
  },
  pinned: {
    uz: "QADALGAN XABARLAR",
    ru: "ЗАКРЕПЛЁННЫЕ",
    en: "PINNED MESSAGES",
  },
  all: {
    uz: "BARCHA XABARLAR",
    ru: "ВСЕ СООБЩЕНИЯ",
    en: "ALL MESSAGES",
  },
  emptyList: {
    uz: "Hali suhbat yo‘q.",
    ru: "Пока нет беседы.",
    en: "No conversations yet.",
  },
  emptyListHint: {
    uz: "Foydalanuvchi mobil ilovadan yozganda suhbat shu yerda paydo bo‘ladi.",
    ru: "Когда пользователь напишет в поддержку через мобильное приложение, беседа появится здесь.",
    en: "When a user writes via the mobile app, the conversation will appear here.",
  },
  emptyThread: {
    uz: "Javob berish uchun chapdan suhbatni tanlang.",
    ru: "Выберите беседу слева, чтобы ответить пользователю.",
    en: "Select a conversation on the left to reply.",
  },
  emptyMessages: {
    uz: "Bu suhbatda hali xabar yo‘q.",
    ru: "Пока нет сообщений в этой беседе.",
    en: "No messages in this conversation yet.",
  },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  draftPlaceholder: {
    uz: "Javob yozing...",
    ru: "Ответ пользователю...",
    en: "Write a reply...",
  },
  noName: { uz: "Nomsiz", ru: "Без имени", en: "No name" },
  noPreview: {
    uz: "Xabarlar yo‘q",
    ru: "Беседа без сообщений",
    en: "No messages yet",
  },
  photoPreview: { uz: "🖼 Foto", ru: "🖼 Фото", en: "🖼 Photo" },
  voicePreview: {
    uz: "🎙 Ovozli xabar",
    ru: "🎙 Голосовое сообщение",
    en: "🎙 Voice message",
  },
  today: { uz: "Bugun", ru: "Сегодня", en: "Today" },
  yesterday: { uz: "Kecha", ru: "Вчера", en: "Yesterday" },
  refreshAria: { uz: "Yangilash", ru: "Обновить", en: "Refresh" },
  newMessageAria: {
    uz: "Yangilash",
    ru: "Обновить",
    en: "Refresh",
  },
  pin: { uz: "Qadash", ru: "Закрепить", en: "Pin" },
  unpin: { uz: "Qadashni olib tashlash", ru: "Открепить", en: "Unpin" },
  verified: { uz: "Tasdiqlangan", ru: "Верифицирован", en: "Verified" },
  grantVerified: {
    uz: "Tasdiqlash",
    ru: "Выдать верификацию",
    en: "Verify user",
  },
  revokeVerified: {
    uz: "Tasdiqni olib tashlash",
    ru: "Снять верификацию",
    en: "Revoke verification",
  },
  saving: { uz: "Saqlanmoqda…", ru: "Сохраняем…", en: "Saving…" },
  verifyConfirm: {
    uz: "Foydalanuvchini tasdiqlaysizmi?",
    ru: "Верифицировать пользователя?",
    en: "Verify this user?",
  },
  unverifyConfirm: {
    uz: "Tasdiqni olib tashlaysizmi?",
    ru: "Снять верификацию у пользователя?",
    en: "Revoke verification for this user?",
  },
  verifyFailed: {
    uz: "Tasdiq holatini yangilab bo‘lmadi. Qayta urinib ko‘ring.",
    ru: "Не удалось обновить статус верификации. Попробуйте ещё раз.",
    en: "Could not update verification. Please try again.",
  },
  userFallback: {
    uz: "Foydalanuvchi",
    ru: "Пользователь",
    en: "User",
  },
} satisfies Record<string, LocalizedText>;
