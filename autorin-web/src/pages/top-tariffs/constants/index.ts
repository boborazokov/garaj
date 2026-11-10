import type { LocalizedText } from "@/lib/i18n";
import type { PromotionPlan } from "@/types";

export const TOP_PLAN_ORDER: PromotionPlan[] = [
  "BASIC",
  "STANDARD",
  "PREMIUM",
  "VIP",
  "TOP",
];

export const TOP_PLAN_LABELS: Record<PromotionPlan, LocalizedText> = {
  BASIC: { uz: "Asosiy (BASIC)", ru: "Базовый (BASIC)", en: "Basic" },
  STANDARD: {
    uz: "Standart (STANDARD)",
    ru: "Стандарт (STANDARD)",
    en: "Standard",
  },
  PREMIUM: { uz: "Premium", ru: "Premium", en: "Premium" },
  VIP: { uz: "VIP", ru: "VIP", en: "VIP" },
  TOP: { uz: "TOP", ru: "TOP", en: "TOP" },
};

export const DEFAULT_DAYS: Record<PromotionPlan, number> = {
  BASIC: 3,
  STANDARD: 7,
  PREMIUM: 14,
  VIP: 30,
  TOP: 45,
};

export const DEFAULT_AMOUNTS: Record<PromotionPlan, number> = {
  BASIC: 15_000,
  STANDARD: 35_000,
  PREMIUM: 70_000,
  VIP: 120_000,
  TOP: 200_000,
};

export const TOP_TARIFFS_TEXTS = {
  title: { uz: "Top tariflari", ru: "Топ тарифы", en: "Top tariffs" },
  subtitle: {
    uz: "Mahsulot, buyurtma va avtoservislar uchun Topga ko'tarish tariflari",
    ru: "Тарифы поднятия в топ для товаров, заявок и автосервисов",
    en: "Boost-to-top tariffs for products, requests and workshops",
  },
  create: { uz: "Tarif yaratish", ru: "Создать тариф", en: "Create tariff" },
  edit: { uz: "Tahrirlash", ru: "Редактировать", en: "Edit" },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  resetAll: {
    uz: "Asliga qaytarish",
    ru: "Сбросить всё",
    en: "Reset defaults",
  },
  plan: { uz: "Tarif", ru: "Тариф", en: "Plan" },
  days: { uz: "Muddat (kun)", ru: "Срок (дней)", en: "Duration (days)" },
  price: { uz: "Narx (UZS)", ru: "Цена (UZS)", en: "Price (UZS)" },
  basePrice: {
    uz: "Asosiy narx (UZS)",
    ru: "Базовая цена (UZS)",
    en: "Base price (UZS)",
  },
  discount: { uz: "Chegirma (%)", ru: "Скидка (%)", en: "Discount (%)" },
  finalPrice: {
    uz: "Yakuniy narx",
    ru: "Итоговая цена",
    en: "Final price",
  },
  priority: { uz: "Prioritet", ru: "Приоритет", en: "Priority" },
  actions: { uz: "Amallar", ru: "Действия", en: "Actions" },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  empty: {
    uz: "Tariflar topilmadi",
    ru: "Тарифы не найдены",
    en: "No tariffs found",
  },
  createTitle: {
    uz: "Yangi tarif",
    ru: "Новый тариф",
    en: "New tariff",
  },
  editTitle: {
    uz: "Tarifni tahrirlash",
    ru: "Редактировать тариф",
    en: "Edit tariff",
  },
  save: { uz: "Saqlash", ru: "Сохранить", en: "Save" },
  saving: { uz: "Saqlanmoqda…", ru: "Сохранение…", en: "Saving…" },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  confirmDeleteTitle: {
    uz: "Tarifni o'chirish",
    ru: "Удалить тариф",
    en: "Delete tariff",
  },
  confirmDelete: {
    uz: "Bu tarif asl narx va muddatga qaytariladi. Davom etasizmi?",
    ru: "Тариф вернётся к значениям по умолчанию. Продолжить?",
    en: "This tariff will reset to defaults. Continue?",
  },
  confirmResetTitle: {
    uz: "Barcha tariflarni asliga qaytarish",
    ru: "Сбросить все тарифы",
    en: "Reset all tariffs",
  },
  confirmReset: {
    uz: "Barcha o'zgarishlar bekor qilinadi. Davom etasizmi?",
    ru: "Все изменения будут сброшены. Продолжить?",
    en: "All custom tariffs will be cleared. Continue?",
  },
  error: {
    uz: "Tarifni saqlab bo'lmadi",
    ru: "Не удалось сохранить тариф",
    en: "Could not save tariff",
  },
  daysHint: {
    uz: "1–365 kun (hafta, oy va hk)",
    ru: "1–365 дней (неделя, месяц и т.д.)",
    en: "1–365 days (week, month, etc.)",
  },
} as const satisfies Record<string, LocalizedText>;
