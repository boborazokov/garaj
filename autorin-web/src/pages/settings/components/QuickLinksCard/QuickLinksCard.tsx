import { Link } from "react-router-dom";
import { useLanguage } from "@/lib/i18n";
import { SETTINGS_TEXTS } from "../../constants";

const LINKS = [
  {
    to: "/admin/top-plans",
    title: SETTINGS_TEXTS.topPlans,
    hint: SETTINGS_TEXTS.topPlansHint,
  },
  {
    to: "/admin/advertisements",
    title: SETTINGS_TEXTS.banners,
    hint: SETTINGS_TEXTS.bannersHint,
  },
] as const;

export function QuickLinksCard() {
  const { t } = useLanguage();

  return (
    <section className="overflow-hidden rounded-[10px] border border-[#e2e8f0] bg-white">
      <div className="border-b border-[#eef0f3] px-4 py-3">
        <h2 className="m-0 text-[14px] font-semibold text-foreground">
          {t(SETTINGS_TEXTS.linksTitle)}
        </h2>
        <p className="mt-1 mb-0 text-[12px] text-muted-foreground">
          {t(SETTINGS_TEXTS.linksSubtitle)}
        </p>
      </div>

      <ul className="m-0 list-none p-0">
        {LINKS.map((item, index) => (
          <li key={item.to}>
            <Link
              to={item.to}
              className={`flex items-center justify-between gap-3 px-4 py-3 text-foreground transition-colors hover:bg-slate-50 ${
                index < LINKS.length - 1 ? "border-b border-[#eef0f3]" : ""
              }`}
            >
              <span className="min-w-0">
                <span className="block text-[13px] font-medium">{t(item.title)}</span>
                <span className="block text-[12px] text-muted-foreground">
                  {t(item.hint)}
                </span>
              </span>
              <span className="shrink-0 text-[12px] font-medium text-[#226DF7]">
                {t(SETTINGS_TEXTS.openLink)}
              </span>
            </Link>
          </li>
        ))}
      </ul>
    </section>
  );
}
