import {
  CalendarDays,
  Eye,
  MapPin,
  Package,
  Phone,
  Star,
  Store,
} from "lucide-react";
import { useLanguage } from "@/lib/i18n";
import { USER_INFO_TEXTS } from "../../constants";
import { formatJoined } from "../../helpers";
import { getMockRating, isMockUserId } from "../../mock";
import type { UserStatsPanelProps } from "../../types";
import { MetricCard } from "../MetricCard";

export function UserStatsPanel({
  user,
  productsCount,
  activeCount,
  viewsCount,
  region,
}: UserStatsPanelProps) {
  const { t, language } = useLanguage();
  const rating = isMockUserId(user._id) ? getMockRating(user._id) : "—";

  const metricCards = [
    {
      icon: Package,
      label: t(USER_INFO_TEXTS.statsProducts),
      value: String(productsCount),
    },
    {
      icon: Store,
      label: t(USER_INFO_TEXTS.statsActive),
      value: String(activeCount),
    },
    {
      icon: Eye,
      label: t(USER_INFO_TEXTS.statsViews),
      value: viewsCount.toLocaleString(
        language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU",
      ),
    },
    {
      icon: Star,
      label: t(USER_INFO_TEXTS.statsRating),
      value: rating,
    },
  ];

  const infoCards = [
    {
      icon: Phone,
      label: t(USER_INFO_TEXTS.phone),
      value: user.phone || "—",
    },
    {
      icon: MapPin,
      label: t(USER_INFO_TEXTS.region),
      value: region?.trim() || t(USER_INFO_TEXTS.unknownRegion),
    },
    {
      icon: CalendarDays,
      label: t(USER_INFO_TEXTS.joined),
      value: formatJoined(user.createdAt, language),
    },
  ];

  return (
    <div className="space-y-2.5">
      <div className="grid grid-cols-2 gap-2.5 xl:grid-cols-4">
        {metricCards.map((card) => (
          <MetricCard key={card.label} {...card} />
        ))}
      </div>

      <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-3">
        {infoCards.map((card) => (
          <MetricCard key={card.label} {...card} />
        ))}
      </div>
    </div>
  );
}
