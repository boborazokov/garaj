import { Link } from "react-router-dom";
import {
  ArrowLeft,
  BadgeCheck,
  CalendarDays,
  Eye,
  MapPin,
  Package,
  Phone,
  ShieldAlert,
  Star,
  Store,
} from "lucide-react";
import { useLanguage } from "@/lib/i18n";
import { USER_INFO_COLORS, USER_INFO_TEXTS } from "../../constants";
import { formatJoined, initialsOf, roleLabel } from "../../helpers";
import { getMockRating, isMockUserId } from "../../mock";
import type { UserProfileCardProps } from "../../types";
import { MetricCard } from "../MetricCard";

export function UserProfileCard({
  user,
  productsCount,
  activeCount,
  viewsCount,
  region,
}: UserProfileCardProps) {
  const { t, language } = useLanguage();
  const verified = user.verified === true;
  const rating = isMockUserId(user._id) ? getMockRating(user._id) : "—";
  const displayName = user.name || user.phone || "—";

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
    <div className="space-y-3">
      <Link
        to="/admin/users"
        className="group inline-flex h-9 items-center gap-2 rounded-[8px] border bg-white pr-3 pl-1.5 text-[13px] font-medium text-slate-600 transition hover:border-[#226DF7]/35 hover:text-slate-900"
        style={{ borderColor: USER_INFO_COLORS.border }}
      >
        <span
          className="flex size-6 items-center justify-center rounded-[6px] transition group-hover:bg-[rgba(34,109,247,0.08)] group-hover:text-[#226DF7]"
          style={{ background: "#f1f5f9", color: USER_INFO_COLORS.muted }}
        >
          <ArrowLeft className="size-3.5" strokeWidth={2} />
        </span>
        {t(USER_INFO_TEXTS.back)}
      </Link>

      <div
        className="overflow-hidden rounded-[10px] border bg-white"
        style={{ borderColor: USER_INFO_COLORS.border }}
      >
        <div
          className="h-[84px] w-full"
          style={{
            background: `linear-gradient(115deg, ${USER_INFO_COLORS.bannerFrom} 0%, ${USER_INFO_COLORS.bannerVia} 48%, ${USER_INFO_COLORS.bannerTo} 100%)`,
          }}
        />
        <div className="flex items-start gap-4 px-5 pb-5 sm:px-6">
          <div
            className="-mt-11 flex size-[88px] shrink-0 items-center justify-center rounded-full border-[3px] border-white text-[22px] font-bold"
            style={{
              background: USER_INFO_COLORS.accentSoft,
              color: USER_INFO_COLORS.accent,
            }}
          >
            {initialsOf(displayName)}
          </div>
          <div className="min-w-0 pt-3">
            <div className="flex min-w-0 flex-wrap items-center gap-2">
              <h1
                className="truncate text-[18px] font-semibold leading-none"
                style={{ color: USER_INFO_COLORS.text }}
              >
                {displayName}
              </h1>
              <span
                className="inline-flex h-[22px] items-center gap-1 rounded-full px-2 text-[12px] font-semibold leading-none"
                style={
                  verified
                    ? { background: "#ecfdf5", color: "#059669" }
                    : {
                        background: "#fff7ed",
                        color: "#c2410c",
                        border: "1px solid #fdba74",
                      }
                }
              >
                {verified ? (
                  <BadgeCheck className="size-3.5" />
                ) : (
                  <ShieldAlert className="size-3.5" />
                )}
                {verified
                  ? t(USER_INFO_TEXTS.verified)
                  : t(USER_INFO_TEXTS.notVerified)}
              </span>
            </div>
            <p
              className="mt-2 text-[13px] leading-none"
              style={{ color: USER_INFO_COLORS.muted }}
            >
              {roleLabel(user.role, t)}
            </p>
          </div>
        </div>
      </div>

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
