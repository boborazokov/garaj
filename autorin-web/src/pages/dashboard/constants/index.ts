import type { LocalizedText } from "@/lib/i18n";

export const DASHBOARD_PERIODS = [
  { days: 7, label: { uz: "7 kun", ru: "7 дней", en: "7 days" } },
  { days: 14, label: { uz: "14 kun", ru: "14 дней", en: "14 days" } },
  { days: 30, label: { uz: "30 kun", ru: "30 дней", en: "30 days" } },
] as const;

export const DASHBOARD_TEXTS = {
  morning: { uz: "Xayrli tong", ru: "Доброе утро", en: "Good morning" },
  afternoon: { uz: "Xayrli kun", ru: "Добрый день", en: "Good afternoon" },
  evening: { uz: "Xayrli kech", ru: "Добрый вечер", en: "Good evening" },
  greetingSuffix: {
    uz: ", mana bozor holati",
    ru: ", вот состояние рынка",
    en: ", here is the marketplace",
  },
  greetingSubtitle: {
    uz: "Bugungi e’lonlar, moderatsiya va oxirgi {days} kundagi savdo faolligi.",
    ru: "Объявления и модерация сегодня, активность за последние {days} дней.",
    en: "Listings and moderation today, and how the last {days} days have gone.",
  },
  openProducts: {
    uz: "Mahsulotlar",
    ru: "Товары",
    en: "Products",
  },
  openModeration: {
    uz: "Moderatsiya",
    ru: "Модерация",
    en: "Moderation",
  },
  chartPeriodTotal: {
    uz: "{value} — shu davrda",
    ru: "{value} за период",
    en: "{value} in the period",
  },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  visitsToday: {
    uz: "Bugungi kirishlar",
    ru: "Визиты сегодня",
    en: "Visits today",
  },
  visitsTodayHint: {
    uz: "Unique foydalanuvchilar",
    ru: "Уникальные пользователи",
    en: "Unique users",
  },
  partsToday: {
    uz: "Bugungi e'lonlar",
    ru: "Товары сегодня",
    en: "Listings today",
  },
  partsTodayHint: {
    uz: "Yangi mahsulotlar",
    ru: "Новые товары",
    en: "New products",
  },
  pending: {
    uz: "Moderatsiyada",
    ru: "На модерации",
    en: "Pending review",
  },
  pendingHint: {
    uz: "Tekshirish navbati",
    ru: "Очередь проверки",
    en: "In the queue",
  },
  users: {
    uz: "Foydalanuvchilar",
    ru: "Пользователи",
    en: "Users",
  },
  usersHint: {
    uz: "Ro'yxatdagi jami",
    ru: "Всего в системе",
    en: "On the register",
  },
  periodLabel: {
    uz: "Oxirgi {days} kun",
    ru: "За последние {days} дн.",
    en: "Last {days} days",
  },
  visitsPeriod: {
    uz: "Kirishlar",
    ru: "Визиты",
    en: "Visits",
  },
  visitsPeriodHint: {
    uz: "Kunlik unique kirishlar yig'indisi",
    ru: "Сумма уникальных визитов по дням",
    en: "Sum of unique daily visits",
  },
  newUsersPeriod: {
    uz: "Yangi registratsiyalar",
    ru: "Новые регистрации",
    en: "New signups",
  },
  newUsersPeriodHint: {
    uz: "Shu davrda ro'yxatdan o'tganlar",
    ru: "Зарегистрировались за период",
    en: "Accounts created in this period",
  },
  partsPeriod: {
    uz: "Yangi mahsulotlar",
    ru: "Новые товары",
    en: "New listings",
  },
  partsPeriodHint: {
    uz: "E'lon qilingan ehtiyot qismlar",
    ru: "Опубликованные запчасти",
    en: "Spare parts published",
  },
  ordersPeriod: {
    uz: "Buyurtmalar",
    ru: "Заявки",
    en: "Orders",
  },
  ordersPeriodHint: {
    uz: "«Menga kerak» so'rovlari",
    ru: "Запросы «Мне нужно»",
    en: "“I need” requests",
  },
  chartTitle: {
    uz: "Kunlik kirishlar",
    ru: "Визиты по дням",
    en: "Visits per day",
  },
  chartMetricVisits: { uz: "Kirishlar", ru: "Визиты", en: "Visits" },
  chartMetricParts: { uz: "Mahsulotlar", ru: "Товары", en: "Listings" },
  chartMetricOrders: { uz: "Buyurtmalar", ru: "Заявки", en: "Orders" },
  platformTitle: {
    uz: "Platforma",
    ru: "Платформа",
    en: "Platform",
  },
  activeParts: {
    uz: "Faol mahsulotlar",
    ru: "Активные товары",
    en: "Active listings",
  },
  allParts: {
    uz: "Barcha mahsulotlar",
    ru: "Все товары",
    en: "All listings",
  },
  workshops: {
    uz: "Avtoservislar",
    ru: "Автосервисы",
    en: "Workshops",
  },
  activeWorkshops: {
    uz: "Faol avtoservislar",
    ru: "Активные автосервисы",
    en: "Active workshops",
  },
  allOrders: {
    uz: "Barcha buyurtmalar",
    ru: "Все заявки",
    en: "All orders",
  },
  footnote: {
    uz: "Kirishlar — kunlik unique foydalanuvchilar. Mahsulot va buyurtmalar — yaratilgan sana bo‘yicha. Vaqt zonasi: Asia/Tashkent.",
    ru: "Визиты — уникальные пользователи за день. Товары и заявки — по дате создания. Часовой пояс: Asia/Tashkent.",
    en: "Visits are unique users per day. Listings and orders use created date. Timezone: Asia/Tashkent.",
  },
} as const satisfies Record<string, LocalizedText>;

/** Soft card elevation used across the dashboard (Pulse-like). */
export const DASHBOARD_CARD =
  "rounded-[14px] border border-[#e8edf3] bg-white shadow-[0_1px_2px_rgba(15,23,42,0.04),0_8px_22px_rgba(15,23,42,0.06)]";
