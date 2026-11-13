import type { LocalizedText } from "@/lib/i18n";
import type { AdminPartsSort, ItemStatus, PromotionPlan } from "@/types";

export const PRODUCTS_PAGE_SIZE = 10;

export const PROMOTE_PLAN_ORDER: PromotionPlan[] = [
  "BASIC",
  "STANDARD",
  "PREMIUM",
  "VIP",
  "TOP",
];

export const PROMOTE_PLAN_LABELS: Record<PromotionPlan, LocalizedText> = {
  BASIC: { uz: "START", ru: "START", en: "START" },
  STANDARD: { uz: "STANDARD", ru: "STANDARD", en: "STANDARD" },
  PREMIUM: { uz: "PRO", ru: "PRO", en: "PRO" },
  VIP: { uz: "VIP", ru: "VIP", en: "VIP" },
  TOP: { uz: "TOP", ru: "TOP", en: "TOP" },
};

export const PRODUCTS_TEXTS = {
  title: { uz: "Mahsulotlar", ru: "Товары", en: "Products" },
  subtitle: {
    uz: "Barcha ehtiyot qismlar, aksessuarlar va e'lonlar",
    ru: "Все запчасти, аксессуары и объявления",
    en: "All spare parts, accessories and listings",
  },
  searchPlaceholder: {
    uz: "Mahsulot qidirish...",
    ru: "Поиск товара...",
    en: "Search products...",
  },
  show: { uz: "Ko'rsatish", ru: "Показать", en: "Show" },
  sort: { uz: "Saralash", ru: "Сортировка", en: "Sort by" },
  filter: { uz: "Filter", ru: "Фильтр", en: "Filter" },
  category: { uz: "Kategoriya", ru: "Категория", en: "Category" },
  status: { uz: "Holat", ru: "Статус", en: "Status" },
  store: { uz: "Do'kon", ru: "Магазин", en: "Store" },
  period: { uz: "Muddat", ru: "Период", en: "Period" },
  all: { uz: "Barchasi", ru: "Все", en: "All" },
  allCategories: { uz: "Barcha kategoriyalar", ru: "Все категории", en: "All categories" },
  allStatus: { uz: "Barcha holatlar", ru: "Все статусы", en: "All status" },
  allStores: { uz: "Barcha do'konlar", ru: "Все магазины", en: "All stores" },
  allPeriods: { uz: "Barcha muddatlar", ru: "За всё время", en: "All time" },
  clearFilters: { uz: "Tozalash", ru: "Сбросить", en: "Clear" },
  allProducts: { uz: "Barcha mahsulotlar", ru: "Все товары", en: "All products" },
  recommendedOnly: { uz: "Tavsiya etilgan", ru: "Рекомендуемые", en: "Recommended" },
  productName: { uz: "Mahsulot nomi", ru: "Название", en: "Product name" },
  postedBy: { uz: "Joylagan", ru: "Разместил", en: "Posted by" },
  unitPrice: { uz: "Narx", ru: "Цена", en: "Price" },
  quantity: { uz: "Soni", ru: "Кол-во", en: "Qty" },
  views: { uz: "Ko'rishlar", ru: "Просмотры", en: "Views" },
  stats: { uz: "Statistika", ru: "Статистика", en: "Stats" },
  statsTitle: {
    uz: "Mahsulot statistikasi",
    ru: "Статистика товара",
    en: "Product statistics",
  },
  phoneClicks: {
    uz: "Telefon bosishlar",
    ru: "Клики по телефону",
    en: "Phone taps",
  },
  shares: { uz: "Ulashishlar", ru: "Поделились", en: "Shares" },
  close: { uz: "Yopish", ru: "Закрыть", en: "Close" },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  pin: { uz: "Tepaga chiqarish", ru: "Поднять вверх", en: "Pin to top" },
  unpin: { uz: "Tavsiyani olib tashlash", ru: "Убрать из рекомендованных", en: "Unpin" },
  promoteTitle: {
    uz: "Tepaga chiqarish",
    ru: "Поднять вверх",
    en: "Pin to top",
  },
  promoteHint: {
    uz: "Mahsulot uchun tarifni tanlang",
    ru: "Выберите тариф для товара",
    en: "Choose a tariff for this product",
  },
  promotePlan: { uz: "Tarif", ru: "Тариф", en: "Plan" },
  promotePlanHint: {
    uz: "Tarifni tanlang",
    ru: "Выберите тариф",
    en: "Select a plan",
  },
  daysShort: { uz: "kun", ru: "дн.", en: "days" },
  promoteConfirm: {
    uz: "Chiqarish",
    ru: "Поднять",
    en: "Boost",
  },
  promoteError: {
    uz: "Tarifni tanlash majburiy",
    ru: "Нужно выбрать тариф",
    en: "A tariff is required",
  },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  empty: { uz: "Mahsulot topilmadi", ru: "Товары не найдены", en: "No products found" },
  selected: { uz: "tanlangan", ru: "выбрано", en: "selected" },
  deleteSelected: { uz: "Tanlanganlarni o'chirish", ru: "Удалить выбранные", en: "Delete selected" },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  save: { uz: "Saqlash", ru: "Сохранить", en: "Save" },
  confirmDeleteTitle: { uz: "Mahsulotni o'chirish", ru: "Удалить товар", en: "Delete product" },
  confirmDelete: {
    uz: "Bu mahsulot butunlay o'chiriladi. Davom etasizmi?",
    ru: "Товар будет удалён безвозвратно. Продолжить?",
    en: "This product will be permanently deleted. Continue?",
  },
  confirmBulkDelete: {
    uz: "Tanlangan mahsulotlar o'chiriladi. Davom etasizmi?",
    ru: "Выбранные товары будут удалены. Продолжить?",
    en: "Selected products will be deleted. Continue?",
  },
  sku: { uz: "SKU", ru: "SKU", en: "SKU" },
  promoted: { uz: "Top", ru: "Топ", en: "Top" },
  prevPage: { uz: "Oldingi", ru: "Назад", en: "Previous" },
  nextPage: { uz: "Keyingi", ru: "Далее", en: "Next" },
  selectAll: { uz: "Barchasini tanlash", ru: "Выбрать все", en: "Select all" },
  selectRow: { uz: "Qatorni tanlash", ru: "Выбрать строку", en: "Select row" },
} as const satisfies Record<string, LocalizedText>;

export const STATUS_LABELS: Record<ItemStatus, LocalizedText> = {
  ACTIVE: { uz: "Faol", ru: "Активен", en: "Active" },
  ARCHIVED: { uz: "Arxiv", ru: "Архив", en: "Archived" },
  PENDING_MODERATION: { uz: "Tekshiruvda", ru: "На проверке", en: "Pending" },
  REJECTED: { uz: "Rad etilgan", ru: "Отклонён", en: "Rejected" },
};

export const SHOW_OPTIONS: { id: string; label: LocalizedText }[] = [
  { id: "all", label: PRODUCTS_TEXTS.all },
  { id: "ACTIVE", label: STATUS_LABELS.ACTIVE },
  { id: "PENDING_MODERATION", label: STATUS_LABELS.PENDING_MODERATION },
  { id: "ARCHIVED", label: STATUS_LABELS.ARCHIVED },
  { id: "REJECTED", label: STATUS_LABELS.REJECTED },
  { id: "recommended", label: PRODUCTS_TEXTS.recommendedOnly },
];

export const SORT_OPTIONS: { id: AdminPartsSort; label: LocalizedText }[] = [
  { id: "NEWEST", label: { uz: "Yangi", ru: "Новые", en: "Newest" } },
  { id: "OLDEST", label: { uz: "Eski", ru: "Старые", en: "Oldest" } },
  { id: "VIEWS", label: { uz: "Ko'p ko'rilgan", ru: "По просмотрам", en: "Most viewed" } },
  { id: "PRICE_ASC", label: { uz: "Arzon", ru: "Дешёвые", en: "Cheap" } },
  { id: "PRICE_DESC", label: { uz: "Qimmat", ru: "Дорогие", en: "Expensive" } },
  { id: "RECOMMENDED", label: { uz: "Tavsiya", ru: "Рекомендуемые", en: "Recommended" } },
];

export const PERIOD_OPTIONS: { id: string; label: LocalizedText; days?: number }[] = [
  { id: "", label: PRODUCTS_TEXTS.allPeriods },
  { id: "today", label: { uz: "Bugun", ru: "Сегодня", en: "Today" }, days: 0 },
  { id: "7d", label: { uz: "7 kun", ru: "7 дней", en: "7 days" }, days: 7 },
  { id: "30d", label: { uz: "30 kun", ru: "30 дней", en: "30 days" }, days: 30 },
  { id: "90d", label: { uz: "90 kun", ru: "90 дней", en: "90 days" }, days: 90 },
];
