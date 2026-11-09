import type { LocalizedText } from "@/lib/i18n";
import type { AdvertisementStatus, CategoryType } from "@/types";

/** Placement surfaces — same CategoryType values the mobile app requests. */
export const PLACEMENT_TYPES: CategoryType[] = [
  "BRAND",
  "PART",
  "SERVICE",
  "MODEL",
  "TUNING",
  "ANNOUNCEMENT",
];

export const PLACEMENT_LABELS: Record<CategoryType, LocalizedText> = {
  BRAND: {
    uz: "Bosh sahifa — yuqori banner",
    ru: "Главная — верхний баннер",
    en: "Home — top banner",
  },
  PART: {
    uz: "Mahsulotlar — top + ro'yxatlar",
    ru: "Товары — верх + списки",
    en: "Products — top + lists",
  },
  SERVICE: {
    uz: "Servislar — top + ro'yxat ichida",
    ru: "Сервисы — верх + в ленте",
    en: "Services — top + in-feed",
  },
  MODEL: {
    uz: "Do'kon sahifasi — banner",
    ru: "Страница магазина — баннер",
    en: "Store page — banner",
  },
  TUNING: {
    uz: "Qidiruv / katalog — explore",
    ru: "Поиск / каталог — explore",
    en: "Search / catalog — explore",
  },
  ANNOUNCEMENT: {
    uz: "Buyurtmalar — yuqori banner",
    ru: "Заявки — верхний баннер",
    en: "Requests — top banner",
  },
};

export const STATUS_OPTIONS: Array<"" | AdvertisementStatus> = [
  "",
  "ACTIVE",
  "PAUSED",
  "QUEUED",
  "EXPIRED",
];

export const STATUS_LABELS: Record<AdvertisementStatus, LocalizedText> = {
  ACTIVE: { uz: "Faol", ru: "Активен", en: "Active" },
  PAUSED: { uz: "To'xtatilgan", ru: "Пауза", en: "Paused" },
  QUEUED: { uz: "Navbatda", ru: "В очереди", en: "Queued" },
  EXPIRED: { uz: "Tugagan", ru: "Истёк", en: "Expired" },
};

export type DurationPreset = "1d" | "7d" | "30d" | "90d" | "custom";

export type AdvertisementPlanId = "DAY" | "WEEK" | "MONTH" | "QUARTER";

export const DURATION_OPTIONS: Array<{
  id: DurationPreset;
  label: LocalizedText;
  days?: number;
  plan?: AdvertisementPlanId;
}> = [
  {
    id: "1d",
    label: { uz: "1 kun", ru: "1 день", en: "1 day" },
    days: 1,
    plan: "DAY",
  },
  {
    id: "7d",
    label: { uz: "1 hafta", ru: "1 неделя", en: "1 week" },
    days: 7,
    plan: "WEEK",
  },
  {
    id: "30d",
    label: { uz: "1 oy", ru: "1 месяц", en: "1 month" },
    days: 30,
    plan: "MONTH",
  },
  {
    id: "90d",
    label: { uz: "3 oy", ru: "3 месяца", en: "3 months" },
    days: 90,
    plan: "QUARTER",
  },
  {
    id: "custom",
    label: { uz: "Maxsus", ru: "Свой срок", en: "Custom" },
  },
];

export const PLAN_LABELS: Record<AdvertisementPlanId, LocalizedText> = {
  DAY: { uz: "1 kun", ru: "1 день", en: "1 day" },
  WEEK: { uz: "1 hafta", ru: "1 неделя", en: "1 week" },
  MONTH: { uz: "1 oy", ru: "1 месяц", en: "1 month" },
  QUARTER: { uz: "3 oy", ru: "3 месяца", en: "3 months" },
};

export const PLAN_COLUMN_ORDER: AdvertisementPlanId[] = [
  "DAY",
  "WEEK",
  "MONTH",
  "QUARTER",
];

/**
 * Local fallback matrix (mirrors backend plan-prices.ts) so the admin table
 * still renders if GraphQL is briefly unavailable.
 */
export const FALLBACK_AD_PRICES_UZS: Record<
  CategoryType,
  Record<AdvertisementPlanId, number>
> = {
  BRAND: { DAY: 35_000, WEEK: 180_000, MONTH: 540_000, QUARTER: 1_350_000 },
  PART: { DAY: 25_000, WEEK: 120_000, MONTH: 360_000, QUARTER: 900_000 },
  SERVICE: { DAY: 28_000, WEEK: 140_000, MONTH: 420_000, QUARTER: 1_050_000 },
  ANNOUNCEMENT: { DAY: 22_000, WEEK: 100_000, MONTH: 300_000, QUARTER: 750_000 },
  TUNING: { DAY: 18_000, WEEK: 85_000, MONTH: 255_000, QUARTER: 640_000 },
  MODEL: { DAY: 15_000, WEEK: 70_000, MONTH: 210_000, QUARTER: 520_000 },
};

export const BANNERS_TEXTS = {
  title: { uz: "Bannerlar", ru: "Баннеры", en: "Banners" },
  subtitle: {
    uz: "Reklama bannerlarini yarating, muddat va statistikani boshqaring",
    ru: "Создавайте рекламные баннеры, управляйте сроками и статистикой",
    en: "Create ad banners, manage duration and stats",
  },
  add: {
    uz: "Banner qo'shish",
    ru: "Добавить баннер",
    en: "Add banner",
  },
  searchPlaceholder: {
    uz: "Banner qidirish...",
    ru: "Поиск баннера...",
    en: "Search banners...",
  },
  placementFilter: {
    uz: "Joylashtirish",
    ru: "Размещение",
    en: "Placement",
  },
  statusFilter: { uz: "Status", ru: "Статус", en: "Status" },
  allStatuses: {
    uz: "Barcha statuslar",
    ru: "Все статусы",
    en: "All statuses",
  },
  clearFilters: {
    uz: "Tozalash",
    ru: "Сбросить",
    en: "Clear",
  },
  banner: { uz: "Banner", ru: "Баннер", en: "Banner" },
  link: { uz: "Havola", ru: "Ссылка", en: "Link" },
  period: { uz: "Muddat", ru: "Срок", en: "Period" },
  status: { uz: "Status", ru: "Статус", en: "Status" },
  stats: { uz: "Statistika", ru: "Статистика", en: "Stats" },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  edit: { uz: "Tahrirlash", ru: "Редактировать", en: "Edit" },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  empty: {
    uz: "Banner topilmadi",
    ru: "Баннеры не найдены",
    en: "No banners found",
  },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  save: { uz: "Saqlash", ru: "Сохранить", en: "Save" },
  saving: { uz: "Saqlanmoqda…", ru: "Сохранение…", en: "Saving…" },
  close: { uz: "Yopish", ru: "Закрыть", en: "Close" },
  createTitle: {
    uz: "Yangi banner",
    ru: "Новый баннер",
    en: "New banner",
  },
  editTitle: {
    uz: "Bannerni tahrirlash",
    ru: "Редактировать баннер",
    en: "Edit banner",
  },
  titleField: { uz: "Sarlavha", ru: "Заголовок", en: "Title" },
  titlePlaceholder: {
    uz: "Masalan: BYD filtrlari",
    ru: "Например: Фильтры BYD",
    en: "e.g. BYD filters",
  },
  linkPlaceholder: {
    uz: "https://… yoki /mahsulot/123",
    ru: "https://… или /product/123",
    en: "https://… or /product/123",
  },
  image: { uz: "Rasm", ru: "Изображение", en: "Image" },
  pickImage: {
    uz: "Rasm tanlang",
    ru: "Выберите изображение",
    en: "Choose image",
  },
  replaceImage: {
    uz: "Rasmni almashtirish",
    ru: "Заменить изображение",
    en: "Replace image",
  },
  removeImage: { uz: "Olib tashlash", ru: "Убрать", en: "Remove" },
  imageHint: {
    uz: "JPG / PNG / WebP, 10 MB gacha",
    ru: "JPG / PNG / WebP, до 10 МБ",
    en: "JPG / PNG / WebP, up to 10 MB",
  },
  duration: { uz: "Davomiylik", ru: "Длительность", en: "Duration" },
  startsAt: {
    uz: "Boshlanish",
    ru: "Начало",
    en: "Start date",
  },
  endsAt: {
    uz: "Tugash",
    ru: "Окончание",
    en: "End date",
  },
  until: { uz: "gacha", ru: "до", en: "until" },
  noEnd: {
    uz: "Muddat yo'q",
    ru: "Без срока",
    en: "No end date",
  },
  impressions: {
    uz: "Ko'rishlar",
    ru: "Показы",
    en: "Impressions",
  },
  clicks: { uz: "Bosishlar", ru: "Клики", en: "Clicks" },
  ctr: { uz: "CTR", ru: "CTR", en: "CTR" },
  statsTitle: {
    uz: "Banner statistikasi",
    ru: "Статистика баннера",
    en: "Banner stats",
  },
  confirmDeleteTitle: {
    uz: "Bannerni o'chirish",
    ru: "Удалить баннер",
    en: "Delete banner",
  },
  confirmDelete: {
    uz: "Bu amalni qaytarib bo'lmaydi.",
    ru: "Это действие нельзя отменить.",
    en: "This cannot be undone.",
  },
  errorRequired: {
    uz: "Barcha majburiy maydonlarni to'ldiring",
    ru: "Заполните все обязательные поля",
    en: "Fill in all required fields",
  },
  errorLink: {
    uz: "Havola https://…, autorin://… yoki /marshrut bo'lishi kerak",
    ru: "Ссылка должна быть https://…, autorin://… или /маршрут",
    en: "Link must be https://…, autorin://… or /route",
  },
  errorImage: {
    uz: "Banner rasmini yuklang",
    ru: "Загрузите изображение баннера",
    en: "Upload a banner image",
  },
  errorDates: {
    uz: "Boshlanish sanasi tugashdan oldin bo'lishi kerak",
    ru: "Дата начала должна быть раньше окончания",
    en: "Start date must be before end date",
  },
  errorSave: {
    uz: "Saqlashda xatolik",
    ru: "Ошибка сохранения",
    en: "Failed to save",
  },
  errorDelete: {
    uz: "O'chirishda xatolik",
    ru: "Ошибка удаления",
    en: "Failed to delete",
  },
  uploading: { uz: "Yuklanmoqda…", ru: "Загрузка…", en: "Uploading…" },
  tariffsTitle: {
    uz: "Reklama tariflari",
    ru: "Тарифы рекламы",
    en: "Ad tariffs",
  },
  tariffsSubtitle: {
    uz: "Joylashtirish × muddat (UZS). O‘zgartiring, saqlang yoki asliga qaytaring.",
    ru: "Размещение × срок (UZS). Меняйте, сохраняйте или сбрасывайте к умолчанию.",
    en: "Placement × duration (UZS). Edit, save, or reset to defaults.",
  },
  tariffsSave: {
    uz: "Tariflarni saqlash",
    ru: "Сохранить тарифы",
    en: "Save tariffs",
  },
  tariffsReset: {
    uz: "Asliga qaytarish",
    ru: "Сбросить",
    en: "Reset defaults",
  },
  tariffsSaveError: {
    uz: "Tariflarni saqlab bo‘lmadi",
    ru: "Не удалось сохранить тарифы",
    en: "Could not save tariffs",
  },
  tariffPrice: {
    uz: "Tarif narxi",
    ru: "Цена тарифа",
    en: "Tariff price",
  },
  tariffSelect: {
    uz: "Tarif",
    ru: "Тариф",
    en: "Tariff",
  },
  tariffSelectHint: {
    uz: "Joy uchun tarifni tanlang — muddat avtomatik qo‘yiladi",
    ru: "Выберите тариф для слота — срок проставится сам",
    en: "Pick a tariff for this slot — dates fill in automatically",
  },
  tariffFree: {
    uz: "Bepul (pilot)",
    ru: "Бесплатно (пилот)",
    en: "Free (pilot)",
  },
  tariffCustomHint: {
    uz: "Maxsus muddat — standart tarif qo'llanilmaydi",
    ru: "Свой срок — стандартный тариф не применяется",
    en: "Custom duration — standard tariff does not apply",
  },
  tariffCol: {
    uz: "Tarif",
    ru: "Тариф",
    en: "Tariff",
  },
  currencyUzs: { uz: "so'm", ru: "сум", en: "UZS" },
  prevPage: {
    uz: "Oldingi sahifa",
    ru: "Предыдущая страница",
    en: "Previous page",
  },
  nextPage: {
    uz: "Keyingi sahifa",
    ru: "Следующая страница",
    en: "Next page",
  },
} as const;
