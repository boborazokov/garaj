import type { LocalizedText } from "@/lib/i18n";
import type { AdminOrdersSort, OrderStatus } from "@/types";

export const ORDERS_PAGE_SIZE = 10;

export const ORDERS_TEXTS = {
  title: { uz: "Buyurtmalar", ru: "Заявки", en: "Orders" },
  subtitle: {
    uz: "Ehtiyot qism so‘rovlari — qidirish, filterlash va boshqarish",
    ru: "Запросы на запчасти — поиск, фильтры и управление",
    en: "Spare-part requests — search, filter and manage",
  },
  searchPlaceholder: {
    uz: "Buyurtma qidirish...",
    ru: "Поиск заявки...",
    en: "Search orders...",
  },
  show: { uz: "Ko'rsatish", ru: "Показать", en: "Show" },
  sort: { uz: "Saralash", ru: "Сортировка", en: "Sort by" },
  category: { uz: "Kategoriya", ru: "Категория", en: "Category" },
  status: { uz: "Holat", ru: "Статус", en: "Status" },
  author: { uz: "Muallif", ru: "Автор", en: "Author" },
  period: { uz: "Muddat", ru: "Период", en: "Period" },
  all: { uz: "Barchasi", ru: "Все", en: "All" },
  clearFilters: { uz: "Tozalash", ru: "Сбросить", en: "Clear" },
  recommendedOnly: { uz: "Tavsiya etilgan", ru: "Рекомендуемые", en: "Recommended" },
  orderTitle: { uz: "Buyurtma", ru: "Заявка", en: "Request" },
  vehicle: { uz: "Avtomobil", ru: "Авто", en: "Vehicle" },
  budget: { uz: "Byudjet", ru: "Бюджет", en: "Budget" },
  negotiable: { uz: "Kelishiladi", ru: "Договорная", en: "Negotiable" },
  location: { uz: "Hudud", ru: "Регион", en: "Region" },
  createdAt: { uz: "Sana", ru: "Дата", en: "Date" },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  stats: { uz: "Statistika", ru: "Статистика", en: "Stats" },
  statsTitle: {
    uz: "Buyurtma statistikasi",
    ru: "Статистика заявки",
    en: "Order statistics",
  },
  views: { uz: "Ko'rishlar", ru: "Просмотры", en: "Views" },
  phoneClicks: {
    uz: "Telefon bosishlar",
    ru: "Клики по телефону",
    en: "Phone taps",
  },
  shares: { uz: "Ulashishlar", ru: "Поделились", en: "Shares" },
  pin: { uz: "Tepaga chiqarish", ru: "Поднять вверх", en: "Pin to top" },
  unpin: { uz: "Tavsiyani olib tashlash", ru: "Убрать из рекомендованных", en: "Unpin" },
  offers: { uz: "Takliflar", ru: "Предложения", en: "Offers" },
  closeOrder: { uz: "Yopish", ru: "Закрыть", en: "Close" },
  reopenOrder: { uz: "Qayta ochish", ru: "Открыть снова", en: "Reopen" },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  empty: { uz: "Buyurtma topilmadi", ru: "Заявки не найдены", en: "No orders found" },
  selected: { uz: "tanlangan", ru: "выбрано", en: "selected" },
  deleteSelected: { uz: "Tanlanganlarni o'chirish", ru: "Удалить выбранные", en: "Delete selected" },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  close: { uz: "Yopish", ru: "Закрыть", en: "Close" },
  confirmDeleteTitle: { uz: "Buyurtmani o'chirish", ru: "Удалить заявку", en: "Delete order" },
  confirmDelete: {
    uz: "Bu buyurtma butunlay o'chiriladi. Davom etasizmi?",
    ru: "Заявка будет удалена безвозвратно. Продолжить?",
    en: "This order will be permanently deleted. Continue?",
  },
  confirmBulkDelete: {
    uz: "Tanlangan buyurtmalar o'chiriladi. Davom etasizmi?",
    ru: "Выбранные заявки будут удалены. Продолжить?",
    en: "Selected orders will be deleted. Continue?",
  },
  confirmCloseTitle: { uz: "Buyurtmani yopish", ru: "Закрыть заявку", en: "Close order" },
  confirmClose: {
    uz: "Buyurtma yopiladi va sotuvchilarga ko‘rinmaydi. Davom etasizmi?",
    ru: "Заявка будет закрыта и скрыта от продавцов. Продолжить?",
    en: "The order will be closed and hidden from sellers. Continue?",
  },
  confirmReopenTitle: {
    uz: "Buyurtmani qayta ochish",
    ru: "Открыть заявку снова",
    en: "Reopen order",
  },
  confirmReopen: {
    uz: "Buyurtma yana faol bo‘ladi va sotuvchilarga ko‘rinadi. Davom etasizmi?",
    ru: "Заявка снова станет активной и появится у продавцов. Продолжить?",
    en: "The order will become active again and visible to sellers. Continue?",
  },
  promoted: { uz: "Top", ru: "Топ", en: "Top" },
  prevPage: { uz: "Oldingi", ru: "Назад", en: "Previous" },
  nextPage: { uz: "Keyingi", ru: "Далее", en: "Next" },
  selectAll: { uz: "Barchasini tanlash", ru: "Выбрать все", en: "Select all" },
  selectRow: { uz: "Qatorni tanlash", ru: "Выбрать строку", en: "Select row" },
  offersTitle: { uz: "Sotuvchi takliflari", ru: "Предложения продавцов", en: "Seller offers" },
  offersEmpty: {
    uz: "Hali taklif yo‘q",
    ru: "Предложений пока нет",
    en: "No offers yet",
  },
  offerPrice: { uz: "Narx", ru: "Цена", en: "Price" },
  deliveryDays: { uz: "Yetkazish", ru: "Доставка", en: "Delivery" },
  daysShort: { uz: "kun", ru: "дн.", en: "d" },
  accepted: { uz: "Qabul qilingan", ru: "Принято", en: "Accepted" },
} as const satisfies Record<string, LocalizedText>;

export const STATUS_LABELS: Record<OrderStatus, LocalizedText> = {
  ACTIVE: { uz: "Faol", ru: "Активна", en: "Active" },
  CLOSED: { uz: "Yopilgan", ru: "Закрыта", en: "Closed" },
  CANCELLED: { uz: "Bekor qilingan", ru: "Отменена", en: "Cancelled" },
};

export const SHOW_OPTIONS: { id: string; label: LocalizedText }[] = [
  { id: "all", label: ORDERS_TEXTS.all },
  { id: "ACTIVE", label: STATUS_LABELS.ACTIVE },
  { id: "CLOSED", label: STATUS_LABELS.CLOSED },
  { id: "CANCELLED", label: STATUS_LABELS.CANCELLED },
  { id: "recommended", label: ORDERS_TEXTS.recommendedOnly },
];

export const SORT_OPTIONS: { id: AdminOrdersSort; label: LocalizedText }[] = [
  { id: "NEWEST", label: { uz: "Yangi", ru: "Новые", en: "Newest" } },
  { id: "OLDEST", label: { uz: "Eski", ru: "Старые", en: "Oldest" } },
  { id: "BUDGET_ASC", label: { uz: "Arzon byudjet", ru: "Дешёвый бюджет", en: "Budget ↑" } },
  { id: "BUDGET_DESC", label: { uz: "Qimmat byudjet", ru: "Дорогой бюджет", en: "Budget ↓" } },
  { id: "RECOMMENDED", label: { uz: "Tavsiya", ru: "Рекомендуемые", en: "Recommended" } },
];

export const PERIOD_OPTIONS: { id: string; label: LocalizedText; days?: number }[] = [
  { id: "", label: { uz: "Barcha muddatlar", ru: "За всё время", en: "All time" } },
  { id: "today", label: { uz: "Bugun", ru: "Сегодня", en: "Today" }, days: 0 },
  { id: "7d", label: { uz: "7 kun", ru: "7 дней", en: "7 days" }, days: 7 },
  { id: "30d", label: { uz: "30 kun", ru: "30 дней", en: "30 days" }, days: 30 },
  { id: "90d", label: { uz: "90 kun", ru: "90 дней", en: "90 days" }, days: 90 },
];
