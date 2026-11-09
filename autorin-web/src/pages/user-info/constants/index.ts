import type { LocalizedText } from "@/lib/i18n";

export const USER_INFO_COLORS = {
  accent: "#226DF7",
  accentSoft: "rgba(34, 109, 247, 0.08)",
  border: "#e2e8f0",
  muted: "#64748b",
  text: "#0f172a",
  textSecondary: "#475569",
  bannerFrom: "#e8f0fe",
  bannerVia: "#f0f6ff",
  bannerTo: "#eef2ff",
} as const;

export const USER_INFO_TEXTS = {
  back: {
    uz: "Foydalanuvchilarga",
    ru: "К пользователям",
    en: "Back to users",
  },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  notFound: {
    uz: "Foydalanuvchi topilmadi",
    ru: "Пользователь не найден",
    en: "User not found",
  },
  seller: { uz: "Sotuvchi", ru: "Продавец", en: "Seller" },
  admin: { uz: "Administrator", ru: "Администратор", en: "Administrator" },
  moderator: { uz: "Moderator", ru: "Модератор", en: "Moderator" },
  user: { uz: "Foydalanuvchi", ru: "Пользователь", en: "User" },
  verified: { uz: "Tasdiqlangan", ru: "Верифицирован", en: "Verified" },
  notVerified: {
    uz: "Tasdiqlanmagan",
    ru: "Не верифицирован",
    en: "Not verified",
  },
  openChat: {
    uz: "Xabarlarga qaytish",
    ru: "К сообщениям",
    en: "Back to messages",
  },
  productsTitle: {
    uz: "Mahsulotlar",
    ru: "Товары",
    en: "Products",
  },
  productsSubtitle: {
    uz: "Ushbu sotuvchining e’lonlari",
    ru: "Объявления этого продавца",
    en: "Listings from this seller",
  },
  emptyProducts: {
    uz: "Mahsulotlar yo‘q",
    ru: "Нет товаров",
    en: "No products",
  },
  product: { uz: "Mahsulot", ru: "Товар", en: "Product" },
  category: { uz: "Kategoriya", ru: "Категория", en: "Category" },
  price: { uz: "Narx", ru: "Цена", en: "Price" },
  status: { uz: "Holat", ru: "Статус", en: "Status" },
  views: { uz: "Ko‘rishlar", ru: "Просмотры", en: "Views" },
  createdAt: { uz: "Sana", ru: "Дата", en: "Date" },
  statsProducts: {
    uz: "Mahsulotlar",
    ru: "Товары",
    en: "Products",
  },
  statsActive: {
    uz: "Faol e’lonlar",
    ru: "Активные",
    en: "Active listings",
  },
  statsViews: {
    uz: "Ko‘rishlar",
    ru: "Просмотры",
    en: "Views",
  },
  statsRating: {
    uz: "Reyting",
    ru: "Рейтинг",
    en: "Rating",
  },
  joined: {
    uz: "Ro‘yxatdan o‘tgan",
    ru: "Зарегистрирован",
    en: "Joined",
  },
  phone: { uz: "Telefon", ru: "Телефон", en: "Phone" },
  region: { uz: "Hudud", ru: "Регион", en: "Region" },
  unknownRegion: {
    uz: "Hudud ko‘rsatilmagan",
    ru: "Регион не указан",
    en: "Region not set",
  },
  ofTotal: {
    uz: "jami e’lonlardan",
    ru: "от всех объявлений",
    en: "of all listings",
  },
  liveNow: {
    uz: "hozir faol",
    ru: "сейчас активны",
    en: "currently live",
  },
  allTime: {
    uz: "barcha vaqt",
    ru: "за всё время",
    en: "all time",
  },
  sellerScore: {
    uz: "sotuvchi bahosi",
    ru: "оценка продавца",
    en: "seller score",
  },
  contactInfo: {
    uz: "aloqa",
    ru: "контакт",
    en: "contact",
  },
  locationInfo: {
    uz: "joylashuv",
    ru: "локация",
    en: "location",
  },
  accountInfo: {
    uz: "akkaunt",
    ru: "аккаунт",
    en: "account",
  },
  walletTitle: {
    uz: "Hamyon",
    ru: "Кошелёк",
    en: "Wallet",
  },
  walletMain: {
    uz: "Asosiy",
    ru: "Основной",
    en: "Main",
  },
  walletBonus: {
    uz: "Bonus",
    ru: "Бонус",
    en: "Bonus",
  },
  walletTotal: {
    uz: "Jami",
    ru: "Итого",
    en: "Total",
  },
  walletCredit: {
    uz: "Hisobni to‘ldirish",
    ru: "Начислить",
    en: "Credit",
  },
  walletAmount: {
    uz: "Summa (UZS)",
    ru: "Сумма (UZS)",
    en: "Amount (UZS)",
  },
  walletNote: {
    uz: "Izoh",
    ru: "Комментарий",
    en: "Note",
  },
  walletPool: {
    uz: "Hisob",
    ru: "Пул",
    en: "Pool",
  },
  walletHistory: {
    uz: "Tranzaksiyalar",
    ru: "Транзакции",
    en: "Transactions",
  },
  walletEmptyTx: {
    uz: "Tranzaksiyalar yo‘q",
    ru: "Нет транзакций",
    en: "No transactions",
  },
  walletSave: {
    uz: "Saqlash",
    ru: "Сохранить",
    en: "Save",
  },
  walletCancel: {
    uz: "Bekor qilish",
    ru: "Отмена",
    en: "Cancel",
  },
} satisfies Record<string, LocalizedText>;

export const STATUS_LABELS: Record<string, LocalizedText> = {
  ACTIVE: { uz: "Faol", ru: "Активен", en: "Active" },
  PENDING_MODERATION: {
    uz: "Moderatsiya",
    ru: "Модерация",
    en: "Pending",
  },
  ARCHIVED: { uz: "Arxiv", ru: "Архив", en: "Archived" },
  REJECTED: { uz: "Rad etilgan", ru: "Отклонён", en: "Rejected" },
};
