import type { LocalizedText } from "@/lib/i18n";

export const SETTINGS_TEXTS = {
  title: { uz: "Sozlamalar", ru: "Настройки", en: "Settings" },
  subtitle: {
    uz: "Moderatsiya, ilova kontaktlari va tezkor bo‘limlar.",
    ru: "Модерация, контакты приложения и быстрые разделы.",
    en: "Moderation, app contacts and quick sections.",
  },
  moderationTitle: {
    uz: "Mahsulot moderatsiyasi",
    ru: "Модерация товаров",
    en: "Product moderation",
  },
  moderationSubtitle: {
    uz: "Yoqilsa — yangi mahsulotlar navbatga tushadi va tasdiqlangunicha katalogda ko‘rinmaydi.",
    ru: "Если включено — новые товары попадают в очередь и скрыты до одобрения.",
    en: "When on, new listings enter the queue and stay hidden until approved.",
  },
  moderationOn: { uz: "Yoqilgan", ru: "Включена", en: "Enabled" },
  moderationOff: { uz: "O‘chirilgan", ru: "Выключена", en: "Disabled" },
  openModeration: {
    uz: "Navbatni ochish",
    ru: "Открыть очередь",
    en: "Open queue",
  },
  contactsTitle: {
    uz: "Ilova kontaktlari",
    ru: "Контакты в приложении",
    en: "App contacts",
  },
  contactsSubtitle: {
    uz: "Mobil ilovada «Biz bilan bog‘laning» bo‘limida chiqadi.",
    ru: "Показываются в приложении в разделе «Свяжитесь с нами».",
    en: "Shown in the app under Contact us.",
  },
  email: { uz: "Email", ru: "Email", en: "Email" },
  phone: { uz: "Telefon", ru: "Телефон", en: "Phone" },
  emailPlaceholder: {
    uz: "support@garage.uz",
    ru: "support@garage.uz",
    en: "support@garage.uz",
  },
  phonePlaceholder: {
    uz: "+998 90 123 45 67",
    ru: "+998 90 123 45 67",
    en: "+998 90 123 45 67",
  },
  save: { uz: "Saqlash", ru: "Сохранить", en: "Save" },
  saving: { uz: "Saqlanmoqda…", ru: "Сохранение…", en: "Saving…" },
  saved: { uz: "Saqlandi", ru: "Сохранено", en: "Saved" },
  saveError: {
    uz: "Saqlab bo‘lmadi",
    ru: "Не удалось сохранить",
    en: "Could not save",
  },
  linksTitle: {
    uz: "Tezkor bo‘limlar",
    ru: "Быстрые разделы",
    en: "Quick links",
  },
  linksSubtitle: {
    uz: "Top tariflar va banner sozlamalari.",
    ru: "Тарифы топа и настройки баннеров.",
    en: "Top tariffs and banner settings.",
  },
  topPlans: { uz: "Top tariflar", ru: "Топ тарифы", en: "Top plans" },
  topPlansHint: {
    uz: "Topga ko‘tarish narxlari va muddatlari",
    ru: "Цены и сроки поднятия в топ",
    en: "Boost prices and durations",
  },
  banners: { uz: "Bannerlar", ru: "Баннеры", en: "Banners" },
  bannersHint: {
    uz: "Reklama bannerlari va tariflari",
    ru: "Рекламные баннеры и тарифы",
    en: "Ad banners and tariffs",
  },
  openLink: { uz: "Ochish", ru: "Открыть", en: "Open" },
  loading: { uz: "Yuklanmoqda…", ru: "Загрузка…", en: "Loading…" },
} as const satisfies Record<string, LocalizedText>;
