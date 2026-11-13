import type { LocalizedText } from "@/lib/i18n";

export const USERS_PAGE_SIZE = 20;

export const USERS_COLORS = {
  accent: "#226DF7",
  accentSoft: "rgba(34, 109, 247, 0.08)",
  border: "#e2e8f0",
  muted: "#64748b",
  text: "#0f172a",
} as const;

export const USERS_TEXTS = {
  title: { uz: "Foydalanuvchilar", ru: "Пользователи", en: "Users" },
  subtitle: {
    uz: "Sotuvchilar, moderatorlar va adminlar",
    ru: "Продавцы, модераторы и админы",
    en: "Sellers, moderators and admins",
  },
  searchPlaceholder: {
    uz: "Ism yoki telefon...",
    ru: "Имя или телефон...",
    en: "Name or phone...",
  },
  role: { uz: "Rol", ru: "Роль", en: "Role" },
  verification: { uz: "Verifikatsiya", ru: "Верификация", en: "Verification" },
  allRoles: { uz: "Barcha rollar", ru: "Все роли", en: "All roles" },
  allVerification: {
    uz: "Barcha holatlar",
    ru: "Все статусы",
    en: "All statuses",
  },
  verifiedOnly: {
    uz: "Tasdiqlangan",
    ru: "Верифицированные",
    en: "Verified",
  },
  unverifiedOnly: {
    uz: "Tasdiqlanmagan",
    ru: "Не верифицированные",
    en: "Unverified",
  },
  clearFilters: { uz: "Tozalash", ru: "Сбросить", en: "Clear" },
  name: { uz: "Ism", ru: "Имя", en: "Name" },
  phone: { uz: "Telefon", ru: "Телефон", en: "Phone" },
  joined: { uz: "Ro‘yxatdan o‘tgan", ru: "Регистрация", en: "Joined" },
  action: { uz: "Amal", ru: "Действие", en: "Action" },
  open: { uz: "Ochish", ru: "Открыть", en: "Open" },
  verify: { uz: "Tasdiqlash", ru: "Верифицировать", en: "Verify" },
  unverify: { uz: "Olib tashlash", ru: "Снять", en: "Remove" },
  verified: { uz: "Tasdiqlangan", ru: "Верифицирован", en: "Verified" },
  notVerified: {
    uz: "Tasdiqlanmagan",
    ru: "Не верифицирован",
    en: "Not verified",
  },
  empty: {
    uz: "Foydalanuvchi topilmadi",
    ru: "Пользователи не найдены",
    en: "No users found",
  },
  loading: { uz: "Yuklanmoqda...", ru: "Загрузка...", en: "Loading..." },
  cancel: { uz: "Bekor qilish", ru: "Отмена", en: "Cancel" },
  confirm: { uz: "Tasdiqlash", ru: "Подтвердить", en: "Confirm" },
  confirmVerifyTitle: {
    uz: "Verifikatsiyani o‘zgartirish",
    ru: "Изменить верификацию",
    en: "Change verification",
  },
  confirmVerify: {
    uz: "Foydalanuvchini tasdiqlaysizmi?",
    ru: "Верифицировать пользователя?",
    en: "Verify this user?",
  },
  confirmUnverify: {
    uz: "Verifikatsiyani olib tashlaysizmi?",
    ru: "Снять верификацию?",
    en: "Remove verification?",
  },
  verifyFailed: {
    uz: "Verifikatsiyani yangilab bo‘lmadi",
    ru: "Не удалось обновить верификацию",
    en: "Could not update verification",
  },
  roleFailed: {
    uz: "Rolni yangilab bo‘lmadi",
    ru: "Не удалось обновить роль",
    en: "Could not update role",
  },
  confirmRoleTitle: {
    uz: "Rolni o‘zgartirish",
    ru: "Изменить роль",
    en: "Change role",
  },
  confirmRoleMessage: {
    uz: "Davom etish uchun o‘z parolingizni kiriting. Tasdiqlamasdan rol o‘zgarmaydi.",
    ru: "Введите свой пароль для подтверждения. Без него роль не изменится.",
    en: "Enter your password to confirm. The role will not change without it.",
  },
  passwordLabel: {
    uz: "Parolingiz",
    ru: "Ваш пароль",
    en: "Your password",
  },
  passwordPlaceholder: {
    uz: "Parol",
    ru: "Пароль",
    en: "Password",
  },
  passwordWrong: {
    uz: "Parol noto‘g‘ri",
    ru: "Неверный пароль",
    en: "Incorrect password",
  },
  passwordRequired: {
    uz: "Parol majburiy",
    ru: "Пароль обязателен",
    en: "Password is required",
  },
  prevPage: { uz: "Oldingi", ru: "Назад", en: "Previous" },
  nextPage: { uz: "Keyingi", ru: "Далее", en: "Next" },
  user: { uz: "Foydalanuvchi", ru: "Пользователь", en: "User" },
  seller: { uz: "Sotuvchi", ru: "Продавец", en: "Seller" },
  admin: { uz: "Administrator", ru: "Администратор", en: "Administrator" },
  moderator: { uz: "Moderator", ru: "Модератор", en: "Moderator" },
} as const satisfies Record<string, LocalizedText>;

export const ROLE_OPTIONS = ["USER", "MODERATOR", "ADMIN"] as const;

export type UserRoleOption = (typeof ROLE_OPTIONS)[number];

export const ROLE_LABELS: Record<UserRoleOption, LocalizedText> = {
  USER: USERS_TEXTS.seller,
  MODERATOR: USERS_TEXTS.moderator,
  ADMIN: USERS_TEXTS.admin,
};
