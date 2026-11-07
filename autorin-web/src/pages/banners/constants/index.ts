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
  BRAND: { uz: "Bosh sahifa", ru: "Главная", en: "Home" },
  PART: { uz: "Mahsulotlar", ru: "Товары", en: "Products" },
  SERVICE: { uz: "Servislar", ru: "Сервисы", en: "Services" },
  MODEL: { uz: "Do'konlar", ru: "Магазины", en: "Stores" },
  TUNING: { uz: "Katalog", ru: "Каталог", en: "Catalog" },
  ANNOUNCEMENT: { uz: "Buyurtmalar", ru: "Заявки", en: "Requests" },
};

export const STATUS_OPTIONS: Array<"" | AdvertisementStatus> = [
  "",
  "ACTIVE",
  "PAUSED",
  "EXPIRED",
];

export const STATUS_LABELS: Record<AdvertisementStatus, LocalizedText> = {
  ACTIVE: { uz: "Faol", ru: "Активен", en: "Active" },
  PAUSED: { uz: "To'xtatilgan", ru: "Пауза", en: "Paused" },
  EXPIRED: { uz: "Tugagan", ru: "Истёк", en: "Expired" },
};

export type DurationPreset = "1d" | "7d" | "30d" | "90d" | "custom";

export const DURATION_OPTIONS: Array<{
  id: DurationPreset;
  label: LocalizedText;
  days?: number;
}> = [
  { id: "1d", label: { uz: "1 kun", ru: "1 день", en: "1 day" }, days: 1 },
  { id: "7d", label: { uz: "1 hafta", ru: "1 неделя", en: "1 week" }, days: 7 },
  { id: "30d", label: { uz: "1 oy", ru: "1 месяц", en: "1 month" }, days: 30 },
  { id: "90d", label: { uz: "3 oy", ru: "3 месяца", en: "3 months" }, days: 90 },
  {
    id: "custom",
    label: { uz: "Maxsus", ru: "Свой срок", en: "Custom" },
  },
];

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
