import type { LocalizedText } from "@/lib/i18n";
import type { CategoryType } from "@/types";

export const CATEGORY_TYPES: CategoryType[] = [
  "BRAND",
  "MODEL",
  "PART",
  "SERVICE",
  "TUNING",
  "ANNOUNCEMENT",
];

export const CATEGORIES_TEXTS = {
  title: { uz: "Kategoriyalar", ru: "Категории", en: "Categories" },
  subtitle: {
    uz: "Avtomobil turlari va ehtiyot qism turlarini boshqaring",
    ru: "Управление марками авто и типами запчастей",
    en: "Manage car brands and spare part types",
  },
  add: {
    uz: "Kategoriya qo'shish",
    ru: "Добавить категорию",
    en: "Add category",
  },
  searchPlaceholder: {
    uz: "Kategoriya qidirish...",
    ru: "Поиск категории...",
    en: "Search categories...",
  },
  typeFilter: { uz: "Tur", ru: "Тип", en: "Type" },
  icon: { uz: "Ikonka", ru: "Иконка", en: "Icon" },
  nameRu: { uz: "Nomi (RU)", ru: "Название (RU)", en: "Name (RU)" },
  nameEn: { uz: "Nomi (EN)", ru: "Название (EN)", en: "Name (EN)" },
  nameUz: { uz: "Nomi (UZ)", ru: "Название (UZ)", en: "Name (UZ)" },
  nameRuPlaceholder: {
    uz: "Masalan: Тормоза",
    ru: "Например: Тормоза",
    en: "e.g. Brakes",
  },
  nameEnPlaceholder: {
    uz: "Masalan: Brakes",
    ru: "Например: Brakes",
    en: "e.g. Brakes",
  },
  nameUzPlaceholder: {
    uz: "Masalan: Tormozlar",
    ru: "Например: Tormozlar",
    en: "e.g. Tormozlar",
  },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  edit: { uz: "Tahrirlash", ru: "Редактировать", en: "Edit" },
  delete: { uz: "O'chirish", ru: "Удалить", en: "Delete" },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  empty: {
    uz: "Kategoriya topilmadi",
    ru: "Категории не найдены",
    en: "No categories found",
  },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  save: { uz: "Saqlash", ru: "Сохранить", en: "Save" },
  saving: { uz: "Saqlanmoqda…", ru: "Сохранение…", en: "Saving…" },
  createTitle: {
    uz: "Yangi kategoriya",
    ru: "Новая категория",
    en: "New category",
  },
  editTitle: {
    uz: "Kategoriyani tahrirlash",
    ru: "Редактировать категорию",
    en: "Edit category",
  },
  uploadIcon: {
    uz: "Rasm yuklash",
    ru: "Загрузить фото",
    en: "Upload image",
  },
  replaceIcon: {
    uz: "Rasmni almashtirish",
    ru: "Заменить фото",
    en: "Replace image",
  },
  removeIcon: {
    uz: "Rasmni olib tashlash",
    ru: "Убрать фото",
    en: "Remove image",
  },
  confirmDeleteTitle: {
    uz: "Kategoriyani o'chirish",
    ru: "Удалить категорию",
    en: "Delete category",
  },
  confirmDelete: {
    uz: "Bu kategoriya o'chiriladi. Davom etasizmi?",
    ru: "Категория будет удалена. Продолжить?",
    en: "This category will be deleted. Continue?",
  },
  errorNames: {
    uz: "Nomini uch tilda to'ldiring",
    ru: "Заполните название на трёх языках",
    en: "Fill in the name in all three languages",
  },
  errorIcon: {
    uz: "Kategoriya ikonkasini yuklang",
    ru: "Загрузите иконку категории",
    en: "Upload a category icon",
  },
  errorImage: {
    uz: "Rasm faylini tanlang",
    ru: "Выберите файл изображения",
    en: "Choose an image file",
  },
  errorSave: {
    uz: "Saqlashda xatolik",
    ru: "Ошибка сохранения",
    en: "Save failed",
  },
  errorDelete: {
    uz: "O'chirishda xatolik",
    ru: "Не удалось удалить",
    en: "Delete failed",
  },
} as const satisfies Record<string, LocalizedText>;

export const TYPE_LABELS: Record<CategoryType, LocalizedText> = {
  BRAND: { uz: "Markalar", ru: "Марки", en: "Brands" },
  MODEL: { uz: "Modellar", ru: "Модели", en: "Models" },
  PART: { uz: "Ehtiyot qismlar", ru: "Запчасти", en: "Parts" },
  SERVICE: { uz: "Xizmatlar", ru: "Услуги", en: "Services" },
  TUNING: { uz: "Tyuning", ru: "Тюнинг", en: "Tuning" },
  ANNOUNCEMENT: { uz: "E'lonlar", ru: "Объявления", en: "Announcements" },
};
