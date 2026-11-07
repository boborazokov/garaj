import type { LocalizedText } from "@/lib/i18n";
import type { AdminWorkshopsSort, ItemStatus } from "@/types";

export const WORKSHOPS_PAGE_SIZE = 10;

export const WORKSHOPS_TEXTS = {
  searchPlaceholder: {
    uz: "Avtoservis qidirish...",
    ru: "Поиск автосервиса...",
    en: "Search workshops...",
  },
  show: { uz: "Ko'rsatish", ru: "Показать", en: "Show" },
  sort: { uz: "Saralash", ru: "Сортировка", en: "Sort by" },
  category: { uz: "Kategoriya", ru: "Категория", en: "Category" },
  status: { uz: "Holat", ru: "Статус", en: "Status" },
  owner: { uz: "Egasi", ru: "Владелец", en: "Owner" },
  period: { uz: "Muddat", ru: "Период", en: "Period" },
  all: { uz: "Barchasi", ru: "Все", en: "All" },
  allPeriods: { uz: "Barcha muddatlar", ru: "За всё время", en: "All time" },
  clearFilters: { uz: "Tozalash", ru: "Сбросить", en: "Clear" },
  recommendedOnly: { uz: "Top", ru: "Топ", en: "Top" },
  workshopName: { uz: "Avtoservis", ru: "Автосервис", en: "Workshop" },
  postedBy: { uz: "Egasi", ru: "Владелец", en: "Owner" },
  location: { uz: "Manzil", ru: "Адрес", en: "Location" },
  services: { uz: "Xizmatlar", ru: "Услуги", en: "Services" },
  stats: { uz: "Statistika", ru: "Статистика", en: "Stats" },
  statsTitle: {
    uz: "Avtoservis statistikasi",
    ru: "Статистика автосервиса",
    en: "Workshop statistics",
  },
  views: { uz: "Ko'rishlar", ru: "Просмотры", en: "Views" },
  phoneClicks: {
    uz: "Telefon bosishlar",
    ru: "Клики по телефону",
    en: "Phone taps",
  },
  contacts: { uz: "Murojaatlar", ru: "Обращения", en: "Contacts" },
  close: { uz: "Yopish", ru: "Закрыть", en: "Close" },
  topPlan: { uz: "TOP", ru: "ТОП", en: "TOP" },
  topUntil: { uz: "gacha", ru: "до", en: "until" },
  noTop: { uz: "Yo'q", ru: "Нет", en: "None" },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  pin: { uz: "Tepaga chiqarish", ru: "Поднять вверх", en: "Pin to top" },
  unpin: { uz: "Topdan olib tashlash", ru: "Убрать из топа", en: "Unpin" },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  empty: {
    uz: "Avtoservis topilmadi",
    ru: "Автосервисы не найдены",
    en: "No workshops found",
  },
  selected: { uz: "tanlangan", ru: "выбрано", en: "selected" },
  deleteSelected: {
    uz: "Tanlanganlarni o'chirish",
    ru: "Удалить выбранные",
    en: "Delete selected",
  },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  confirmDeleteTitle: {
    uz: "Avtoservisni o'chirish",
    ru: "Удалить автосервис",
    en: "Delete workshop",
  },
  confirmDelete: {
    uz: "Bu avtoservis butunlay o'chiriladi. Davom etasizmi?",
    ru: "Автосервис будет удалён безвозвратно. Продолжить?",
    en: "This workshop will be permanently deleted. Continue?",
  },
  confirmBulkDelete: {
    uz: "Tanlangan avtoservislar o'chiriladi. Davom etasizmi?",
    ru: "Выбранные автосервисы будут удалены. Продолжить?",
    en: "Selected workshops will be deleted. Continue?",
  },
  idLabel: { uz: "ID", ru: "ID", en: "ID" },
  promoted: { uz: "Top", ru: "Топ", en: "Top" },
  verified: { uz: "Tasdiqlangan", ru: "Проверен", en: "Verified" },
  prevPage: { uz: "Oldingi", ru: "Назад", en: "Previous" },
  nextPage: { uz: "Keyingi", ru: "Далее", en: "Next" },
  selectAll: { uz: "Barchasini tanlash", ru: "Выбрать все", en: "Select all" },
  selectRow: { uz: "Qatorni tanlash", ru: "Выбрать строку", en: "Select row" },
} as const satisfies Record<string, LocalizedText>;

/** ClickUp moderation labels mapped onto ItemStatus. */
export const STATUS_LABELS: Record<ItemStatus, LocalizedText> = {
  ACTIVE: { uz: "Approved", ru: "Approved", en: "Approved" },
  ARCHIVED: { uz: "Hidden", ru: "Hidden", en: "Hidden" },
  PENDING_MODERATION: { uz: "Pending", ru: "Pending", en: "Pending" },
  REJECTED: { uz: "Rejected", ru: "Rejected", en: "Rejected" },
};

export const PROMOTION_PLAN_LABELS: Record<string, LocalizedText> = {
  BASIC: { uz: "Basic", ru: "Basic", en: "Basic" },
  STANDARD: { uz: "Standard", ru: "Standard", en: "Standard" },
  PREMIUM: { uz: "Premium", ru: "Premium", en: "Premium" },
  VIP: { uz: "VIP", ru: "VIP", en: "VIP" },
  TOP: { uz: "TOP", ru: "TOP", en: "TOP" },
};

export const SHOW_OPTIONS: { id: string; label: LocalizedText }[] = [
  { id: "all", label: WORKSHOPS_TEXTS.all },
  { id: "ACTIVE", label: STATUS_LABELS.ACTIVE },
  { id: "PENDING_MODERATION", label: STATUS_LABELS.PENDING_MODERATION },
  { id: "ARCHIVED", label: STATUS_LABELS.ARCHIVED },
  { id: "REJECTED", label: STATUS_LABELS.REJECTED },
  { id: "recommended", label: WORKSHOPS_TEXTS.recommendedOnly },
];

export const SORT_OPTIONS: { id: AdminWorkshopsSort; label: LocalizedText }[] = [
  { id: "NEWEST", label: { uz: "Yangi", ru: "Новые", en: "Newest" } },
  { id: "OLDEST", label: { uz: "Eski", ru: "Старые", en: "Oldest" } },
  { id: "VIEWS", label: { uz: "Ko'p ko'rilgan", ru: "По просмотрам", en: "Most viewed" } },
  { id: "RECOMMENDED", label: { uz: "Top", ru: "Топ", en: "Top" } },
];

export const PERIOD_OPTIONS: { id: string; label: LocalizedText; days?: number }[] = [
  { id: "", label: WORKSHOPS_TEXTS.allPeriods },
  { id: "today", label: { uz: "Bugun", ru: "Сегодня", en: "Today" }, days: 0 },
  { id: "7d", label: { uz: "7 kun", ru: "7 дней", en: "7 days" }, days: 7 },
  { id: "30d", label: { uz: "30 kun", ru: "30 дней", en: "30 days" }, days: 30 },
  { id: "90d", label: { uz: "90 kun", ru: "90 дней", en: "90 days" }, days: 90 },
];
