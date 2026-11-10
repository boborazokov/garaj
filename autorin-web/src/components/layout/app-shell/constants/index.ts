import {
  ClipboardList,
  FolderTree,
  Image,
  LayoutDashboard,
  MessageSquare,
  Package,
  Settings,
  ShieldCheck,
  TrendingUp,
  Users,
  Wrench,
} from "lucide-react";
import type { LocalizedText } from "@/lib/i18n";
import type { AppNavGroup } from "../types";

export const SHELL_COLORS = {
  pageBg: "#ffffff",
  cardBg: "#ffffff",
  sidebarBorder: "#eef0f3",
  border: "#e2e8f0",
  textPrimary: "#111827",
  textSecondary: "#6b7280",
  textMuted: "#9aa3af",
  navActiveBg: "#f3f4f6",
  navHoverBg: "#f8fafc",
  accent: "#226DF7",
  accentSoft: "rgba(34, 109, 247, 0.08)",
  danger: "#ef4444",
  avatarBg: "#111827",
} as const;

export const SHELL_TEXTS = {
  brand: { uz: "AutoRin", ru: "AutoRin", en: "AutoRin" },
  searchPlaceholder: { uz: "O'tish...", ru: "Перейти...", en: "Go to..." },
  searchAria: { uz: "Sahifaga o'tish", ru: "Перейти на страницу", en: "Go to page" },
  searchEmpty: {
    uz: "Mos sahifa topilmadi",
    ru: "Страница не найдена",
    en: "No matching page",
  },
  notificationsAria: { uz: "Xabarlar", ru: "Сообщения", en: "Messages" },
  languageAria: { uz: "Tilni tanlang", ru: "Выберите язык", en: "Select language" },
  menuAria: { uz: "Menyu", ru: "Меню", en: "Menu" },
  closeMenuAria: { uz: "Menyuni yopish", ru: "Закрыть меню", en: "Close menu" },
  collapseAria: {
    uz: "Yon panelni yig'ish",
    ru: "Свернуть боковую панель",
    en: "Collapse sidebar",
  },
  expandAria: {
    uz: "Yon panelni ochish",
    ru: "Развернуть боковую панель",
    en: "Expand sidebar",
  },
  signOut: { uz: "Chiqish", ru: "Выйти", en: "Sign out" },
  administrator: {
    uz: "Administrator",
    ru: "Администратор",
    en: "Administrator",
  },
  moderator: { uz: "Moderator", ru: "Модератор", en: "Moderator" },
} as const satisfies Record<string, LocalizedText>;

export const ADMIN_NAV_GROUPS: AppNavGroup[] = [
  {
    id: "overview",
    label: { uz: "Umumiy", ru: "Обзор", en: "Overview" },
    items: [
      {
        to: "/admin",
        label: { uz: "Boshqaruv", ru: "Дашборд", en: "Dashboard" },
        icon: LayoutDashboard,
        end: true,
      },
    ],
  },
  {
    id: "catalog",
    label: { uz: "Katalog", ru: "Каталог", en: "Catalog" },
    items: [
      {
        to: "/admin/categories",
        label: { uz: "Kategoriyalar", ru: "Категории", en: "Categories" },
        icon: FolderTree,
      },
      {
        to: "/admin/products",
        label: { uz: "Mahsulotlar", ru: "Товары", en: "Products" },
        icon: Package,
      },
      {
        to: "/admin/workshops",
        label: { uz: "Avtoservislar", ru: "Автосервисы", en: "Workshops" },
        icon: Wrench,
      },
      {
        to: "/admin/advertisements",
        label: { uz: "Bannerlar", ru: "Баннеры", en: "Banners" },
        icon: Image,
      },
      {
        to: "/admin/top-plans",
        label: { uz: "Top plans", ru: "Top plans", en: "Top plans" },
        icon: TrendingUp,
      },
    ],
  },
  {
    id: "operations",
    label: { uz: "Ish jarayoni", ru: "Операции", en: "Operations" },
    items: [
      {
        to: "/admin/moderation",
        label: { uz: "Moderatsiya", ru: "Модерация", en: "Moderation" },
        icon: ShieldCheck,
      },
      {
        to: "/admin/orders",
        label: { uz: "Buyurtmalar", ru: "Заявки", en: "Orders" },
        icon: ClipboardList,
      },
      {
        to: "/admin/messages",
        label: { uz: "Xabarlar", ru: "Сообщения", en: "Messages" },
        icon: MessageSquare,
        badgeKey: "messages",
      },
    ],
  },
  {
    id: "team",
    label: { uz: "Jamoa", ru: "Команда", en: "Team" },
    items: [
      {
        to: "/admin/users",
        label: { uz: "Foydalanuvchilar", ru: "Пользователи", en: "Users" },
        icon: Users,
      },
    ],
  },
  {
    id: "system",
    label: { uz: "Tizim", ru: "Система", en: "System" },
    items: [
      {
        to: "/admin/settings",
        label: { uz: "Sozlamalar", ru: "Настройки", en: "Settings" },
        icon: Settings,
      },
    ],
  },
];

export const MODERATOR_NAV_GROUPS: AppNavGroup[] = [
  {
    id: "overview",
    label: { uz: "Umumiy", ru: "Обзор", en: "Overview" },
    items: [
      {
        to: "/moderator",
        label: { uz: "Navbat", ru: "Очередь", en: "Queue" },
        icon: ShieldCheck,
        end: true,
      },
    ],
  },
];

export const SIDEBAR_COLLAPSED_KEY = "autorin-sidebar-collapsed";
