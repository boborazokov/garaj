import type { LucideIcon } from "lucide-react";
import type { AuthUser } from "@/lib/auth";
import type { LocalizedText } from "@/lib/i18n";

export type NavBadgeKey = "messages";

export interface AppNavItem {
  to: string;
  label: LocalizedText;
  icon: LucideIcon;
  end?: boolean;
  badgeKey?: NavBadgeKey;
}

export interface AppNavGroup {
  id: string;
  label: LocalizedText;
  items: AppNavItem[];
}

export interface AppShellProps {
  user: AuthUser;
  groups: AppNavGroup[];
  homeTo: string;
  notificationsTo?: string;
  badges?: Partial<Record<NavBadgeKey, number>>;
}
