import { Skeleton } from "@/components/ui/skeleton";
import { useLanguage } from "@/lib/i18n";
import { DASHBOARD_CARD, DASHBOARD_TEXTS } from "../../constants";
import { formatCompact } from "../../helpers";

interface PlatformStripProps {
  items: { labelKey: keyof typeof DASHBOARD_TEXTS; value: number | undefined }[];
  loading?: boolean;
}

export function PlatformStrip({ items, loading }: PlatformStripProps) {
  const { t, language } = useLanguage();

  return (
    <section className={`${DASHBOARD_CARD} px-4 py-4`}>
      <p className="m-0 mb-3 text-[11px] font-semibold tracking-[0.07em] text-slate-400 uppercase">
        {t(DASHBOARD_TEXTS.platformTitle)}
      </p>
      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
        {items.map((item) => {
          const showSkeleton = Boolean(loading && item.value == null);
          return (
            <div key={item.labelKey} className="min-w-0 rounded-[12px] bg-[#f7f8fa] px-3 py-2.5">
              <p className="m-0 text-[12px] text-slate-500">{t(DASHBOARD_TEXTS[item.labelKey])}</p>
              {showSkeleton ? (
                <Skeleton className="mt-2 h-6 w-14" />
              ) : (
                <p className="mt-1 mb-0 text-[22px] font-semibold tracking-tight text-slate-900 tabular-nums">
                  {formatCompact(item.value ?? 0, language)}
                </p>
              )}
            </div>
          );
        })}
      </div>
    </section>
  );
}
