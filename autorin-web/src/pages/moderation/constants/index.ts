import type { LocalizedText } from "@/lib/i18n";

export const MODERATION_PAGE_SIZE = 10;

export const MODERATION_TEXTS = {
  searchPlaceholder: {
    uz: "E'lon yoki sotuvchi...",
    ru: "Объявление или продавец...",
    en: "Listing or seller...",
  },
  clearFilters: { uz: "Tozalash", ru: "Сбросить", en: "Clear" },
  product: { uz: "Mahsulot", ru: "Товар", en: "Product" },
  seller: { uz: "Sotuvchi", ru: "Продавец", en: "Seller" },
  category: { uz: "Kategoriya", ru: "Категория", en: "Category" },
  price: { uz: "Narx", ru: "Цена", en: "Price" },
  submitted: { uz: "Yuborilgan", ru: "Отправлено", en: "Submitted" },
  action: { uz: "Amallar", ru: "Действия", en: "Actions" },
  approve: { uz: "Tasdiqlash", ru: "Одобрить", en: "Approve" },
  reject: { uz: "Rad etish", ru: "Отклонить", en: "Reject" },
  empty: {
    uz: "Navbat bo'sh — tekshirish uchun e'lon yo'q.",
    ru: "Очередь пуста — нет объявлений на проверке.",
    en: "Queue is empty — nothing pending review.",
  },
  sku: { uz: "SKU", ru: "SKU", en: "SKU" },
  prevPage: { uz: "Oldingi", ru: "Назад", en: "Previous" },
  nextPage: { uz: "Keyingi", ru: "Далее", en: "Next" },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  confirmApproveTitle: {
    uz: "E'lonni tasdiqlash",
    ru: "Одобрить объявление",
    en: "Approve listing",
  },
  confirmApprove: {
    uz: "Bu e'lon faol bo'ladi va bozorda ko'rinadi.",
    ru: "Объявление станет активным и появится в каталоге.",
    en: "This listing will become active and visible in the catalog.",
  },
  rejectTitle: {
    uz: "E'lonni rad etish",
    ru: "Отклонить объявление",
    en: "Reject listing",
  },
  rejectHint: {
    uz: "Sotuvchiga ko'rinadigan sababni yozing.",
    ru: "Укажите причину — её увидит продавец.",
    en: "Write a reason the seller will see.",
  },
  rejectPlaceholder: {
    uz: "Rad etish sababi...",
    ru: "Причина отклонения...",
    en: "Rejection reason...",
  },
  confirmReject: {
    uz: "Rad etishni tasdiqlash",
    ru: "Подтвердить отклонение",
    en: "Confirm rejection",
  },
  approveFailed: {
    uz: "Tasdiqlab bo'lmadi",
    ru: "Не удалось одобрить",
    en: "Could not approve",
  },
  rejectFailed: {
    uz: "Rad etib bo'lmadi",
    ru: "Не удалось отклонить",
    en: "Could not reject",
  },
  noteRequired: {
    uz: "Sabab majburiy",
    ru: "Причина обязательна",
    en: "Reason is required",
  },
  description: { uz: "Tavsif", ru: "Описание", en: "Description" },
  brandModel: { uz: "Marka / model", ru: "Марка / модель", en: "Brand / model" },
  quantity: { uz: "Soni", ru: "Кол-во", en: "Qty" },
  location: { uz: "Manzil", ru: "Адрес", en: "Location" },
  region: { uz: "Hudud", ru: "Регион", en: "Region" },
  condition: { uz: "Holat", ru: "Состояние", en: "Condition" },
  conditionNew: { uz: "Yangi", ru: "Новый", en: "New" },
  conditionUsed: { uz: "Ishlatilgan", ru: "Б/у", en: "Used" },
  negotiable: { uz: "Narx kelishiladi", ru: "Торг уместен", en: "Negotiable" },
  delivery: { uz: "Yetkazib berish", ru: "Доставка", en: "Delivery" },
  deliveryIncluded: { uz: "Mavjud", ru: "Есть", en: "Available" },
  deliveryNotIncluded: { uz: "Mavjud emas", ru: "Нет", en: "Not available" },
  deliveryContract: {
    uz: "Kelishuv bo‘yicha",
    ru: "По договорённости",
    en: "By agreement",
  },
  sellerAddress: { uz: "Sotuvchi manzili", ru: "Адрес продавца", en: "Seller address" },
  noImages: {
    uz: "Rasm yuklanmagan",
    ru: "Нет изображений",
    en: "No images",
  },
} as const satisfies Record<string, LocalizedText>;
