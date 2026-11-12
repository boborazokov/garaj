import { Link } from "react-router-dom";
import { useLanguage } from "@/lib/i18n";
import { SETTINGS_TEXTS } from "../../constants";
import type { ModerationCardProps } from "../../types";

export function ModerationCard({ enabled, busy, onToggle }: ModerationCardProps) {
  const { t } = useLanguage();

  return (
    <section className="overflow-hidden rounded-[10px] border border-[#e2e8f0] bg-white">
      <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-3.5">
        <div className="min-w-0 flex-1">
          <h2 className="m-0 text-[14px] font-semibold text-foreground">
            {t(SETTINGS_TEXTS.moderationTitle)}
          </h2>
          <p className="mt-1 mb-0 max-w-2xl text-[12px] leading-5 text-muted-foreground">
            {t(SETTINGS_TEXTS.moderationSubtitle)}
          </p>
        </div>

        <div className="flex shrink-0 items-center gap-3">
          <span
            className={`text-[12px] font-medium ${
              enabled ? "text-[#226DF7]" : "text-muted-foreground"
            }`}
          >
            {enabled
              ? t(SETTINGS_TEXTS.moderationOn)
              : t(SETTINGS_TEXTS.moderationOff)}
          </span>
          <button
            type="button"
            role="switch"
            aria-checked={enabled}
            disabled={busy}
            onClick={onToggle}
            className={`relative h-7 w-12 rounded-full transition-colors disabled:opacity-60 ${
              enabled ? "bg-[#226DF7]" : "bg-slate-200"
            }`}
          >
            <span
              className={`absolute top-0.5 size-6 rounded-full bg-white shadow-sm transition-[left] ${
                enabled ? "left-[22px]" : "left-0.5"
              }`}
            />
          </button>
        </div>
      </div>

      {enabled ? (
        <div className="border-t border-[#eef0f3] px-4 py-2.5">
          <Link
            to="/admin/moderation"
            className="text-[13px] font-medium text-[#226DF7] hover:underline"
          >
            {t(SETTINGS_TEXTS.openModeration)}
          </Link>
        </div>
      ) : null}
    </section>
  );
}
