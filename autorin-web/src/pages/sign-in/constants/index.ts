import carPartsRepairImg from "@/assets/images/car-parts-repair-garage.jpg";
import carAccessoriesImg from "@/assets/images/different-car-accessories-arrangement.jpg";
import redPadsImg from "@/assets/images/red-pads-pedal-wheel-car.jpg";
import type { LocalizedText } from "@/lib/i18n";
import type { SliderItem } from "../types";

export const SLIDER_ITEMS: SliderItem[] = [
  {
    id: 1,
    image: carPartsRepairImg,
    alt: {
      uz: "AutoRin — Sifatli ehtiyot qismlar",
      ru: "AutoRin — качественные автозапчасти",
      en: "AutoRin — quality car parts",
    },
    subtitle: {
      uz: "Boshqaruv",
      ru: "Управление",
      en: "Control",
    },
    title: {
      uz: "Ehtiyot qismlar katalogini bitta joydan yuriting",
      ru: "Ведите каталог запчастей в одном месте",
      en: "Run the spare-parts catalog from one place",
    },
    description: {
      uz: "E'lonlar, brendlar va kategoriyalarni oson boshqaring.",
      ru: "Легко управляйте объявлениями, брендами и категориями.",
      en: "Manage listings, brands and categories with ease.",
    },
  },
  {
    id: 2,
    image: carAccessoriesImg,
    alt: {
      uz: "Keng turdagi avto aksessuarlar",
      ru: "Широкий выбор автоаксессуаров",
      en: "Wide range of car accessories",
    },
    subtitle: {
      uz: "Savdo",
      ru: "Продажи",
      en: "Sales",
    },
    title: {
      uz: "Buyurtma va omborni birga kuzating",
      ru: "Следите за заказами и складом вместе",
      en: "Track orders and stock together",
    },
    description: {
      uz: "Detallar, aksessuarlar va sarf materiallari doim ko'z oldingizda.",
      ru: "Детали, аксессуары и расходники всегда под рукой.",
      en: "Parts, accessories and consumables stay in view.",
    },
  },
  {
    id: 3,
    image: redPadsImg,
    alt: {
      uz: "Qulay xarid va tez yetkazib berish",
      ru: "Удобная покупка и быстрая доставка",
      en: "Convenient purchase and fast delivery",
    },
    subtitle: {
      uz: "Moderatsiya",
      ru: "Модерация",
      en: "Moderation",
    },
    title: {
      uz: "Ishonchli yetkazib beruvchilar bilan ishlang",
      ru: "Работайте с проверенными поставщиками",
      en: "Work with verified suppliers",
    },
    description: {
      uz: "E'lonlarni tekshiring, sellerlarni nazorat qiling.",
      ru: "Проверяйте объявления и контролируйте продавцов.",
      en: "Review listings and keep sellers in check.",
    },
  },
];

export const SIGN_IN_TEXTS = {
  brandTitle: {
    uz: "AutoRin",
    ru: "AutoRin",
    en: "AutoRin",
  },
  brandSubtitle: {
    uz: "Avtomobil ehtiyot qismlari platformasi",
    ru: "Платформа автомобильных запчастей",
    en: "Car parts platform",
  },
  title: {
    uz: "Xush kelibsiz!",
    ru: "С возвращением!",
    en: "Welcome Back!",
  },
  subtitle: {
    uz: "Ehtiyot qismlar, buyurtmalar va yetkazib beruvchilarni bitta joydan boshqaring.",
    ru: "Управляйте запчастями, заказами и поставщиками в одном месте.",
    en: "Manage parts, orders and suppliers in one place.",
  },
  googleButton: {
    uz: "Google orqali kirish",
    ru: "Войти через Google",
    en: "Login with Google",
  },
  phoneLabel: {
    uz: "Telefon raqam",
    ru: "Номер телефона",
    en: "Phone number",
  },
  phonePlaceholder: {
    uz: "90 123 45 67",
    ru: "90 123 45 67",
    en: "90 123 45 67",
  },
  passwordLabel: {
    uz: "Parol",
    ru: "Пароль",
    en: "Password",
  },
  passwordPlaceholder: {
    uz: "••••••••••",
    ru: "••••••••••",
    en: "••••••••••",
  },
  forgotPassword: {
    uz: "Parolni unutdingizmi?",
    ru: "Забыли пароль?",
    en: "Forgot password?",
  },
  submitButton: {
    uz: "Boshlash",
    ru: "Начать",
    en: "Get Started",
  },
  submitting: {
    uz: "Kirilmoqda...",
    ru: "Вход...",
    en: "Logging in...",
  },
  skipForNow: {
    uz: "hozircha o'tkazib yuborish →",
    ru: "пропустить →",
    en: "skip for now →",
  },
  loginSuccess: {
    uz: "Muvaffaqiyatli tizimga kirildi",
    ru: "Вы успешно вошли в систему",
    en: "Successfully signed in",
  },
  googleNotice: {
    uz: "Google orqali kirish hozircha tez orada ishga tushadi",
    ru: "Вход через Google скоро будет доступен",
    en: "Google sign-in will be available soon",
  },
  accessDenied: {
    uz: "Faqat administrator va moderatorlar uchun ruxsat berilgan",
    ru: "Доступ только для администраторов и модераторов",
    en: "Access is allowed only for administrators and moderators",
  },
  invalidPhoneOrPassword: {
    uz: "Login yoki parolingiz xato",
    ru: "Неверный логин или пароль",
    en: "Incorrect login or password",
  },
  phoneRequired: {
    uz: "Iltimos, telefon raqamingizni kiriting",
    ru: "Пожалуйста, введите номер телефона",
    en: "Please enter your phone number",
  },
  phoneInvalid: {
    uz: "Telefon raqamini to'liq kiriting (9 ta raqam)",
    ru: "Введите номер телефона полностью (9 цифр)",
    en: "Enter the full phone number (9 digits)",
  },
  passwordRequired: {
    uz: "Iltimos, parolingizni kiriting",
    ru: "Пожалуйста, введите пароль",
    en: "Please enter your password",
  },
  loginSuccessTitle: {
    uz: "Kirish muvaffaqiyatli",
    ru: "Вход выполнен",
    en: "Sign-in successful",
  },
  loginFailedTitle: {
    uz: "Kirish muvaffaqiyatsiz",
    ru: "Ошибка входа",
    en: "Sign-in failed",
  },
  loginErrorTitle: {
    uz: "Kirishda xatolik",
    ru: "Ошибка при входе",
    en: "Sign-in error",
  },
  accessDeniedTitle: {
    uz: "Ruxsat yo'q",
    ru: "Нет доступа",
    en: "Access denied",
  },
  googleLoginTitle: {
    uz: "Google orqali kirish",
    ru: "Вход через Google",
    en: "Sign in with Google",
  },
  forgotPasswordTitle: {
    uz: "Parolni tiklash",
    ru: "Восстановление пароля",
    en: "Reset password",
  },
  forgotPasswordDescription: {
    uz: "Parolni tiklash uchun qo'llab-quvvatlash xizmatiga murojaat qiling.",
    ru: "Для восстановления пароля обратитесь в службу поддержки.",
    en: "Contact support to reset your password.",
  },
  phoneInvalidTitle: {
    uz: "Telefon raqami xato",
    ru: "Неверный номер телефона",
    en: "Invalid phone number",
  },
  apiUnreachable: {
    uz: "API ga ulanib bo'lmadi. Backend server ishga tushganligini tekshiring.",
    ru: "Не удалось подключиться к API. Проверьте, запущен ли сервер.",
    en: "Could not connect to the API. Make sure the backend server is running.",
  },
  loginGenericError: {
    uz: "Kirishda xatolik yuz berdi. Telefon raqami yoki parolni tekshiring.",
    ru: "Произошла ошибка входа. Проверьте номер телефона или пароль.",
    en: "Sign-in failed. Check your phone number or password.",
  },
  languageAria: {
    uz: "Tilni tanlang",
    ru: "Выберите язык",
    en: "Select language",
  },
  helpSupport: {
    uz: "Yordam va qo'llab-quvvatlash",
    ru: "Помощь и поддержка",
    en: "Help and support",
  },
  helpSupportDescription: {
    uz: "Yordam uchun qo'llab-quvvatlash xizmatiga murojaat qiling.",
    ru: "Для помощи обратитесь в службу поддержки.",
    en: "Contact support if you need help.",
  },
} as const satisfies Record<string, LocalizedText>;

export const SIGN_IN_COLORS = {
  primary: "#226DF7",
  primaryHover: "#1b5cd4",
  primaryActive: "#164bb0",
  primaryLight: "rgba(34, 109, 247, 0.08)",
  primaryBorder: "#8bb6fb",
  background: "#f1f3f9",
  cardBg: "#ffffff",
  textPrimary: "#111827",
  textSecondary: "#6b7280",
  textMuted: "#9ca3af",
  inputBorder: "#e2e8f0",
  inputBorderFocus: "#226DF7",
  error: "#ef4444",
} as const;
