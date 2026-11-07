import { useLanguage } from "@/lib/i18n";
import { DASHBOARD_PERIODS, DASHBOARD_TEXTS } from "../../constants";
import { firstName, greetingKey } from "../../helpers";
import { SegmentedTabs } from "../SegmentedTabs";

interface GreetingBarProps {
  userName: string;
  days: number;
  onDaysChange: (days: number) => void;
}

export function GreetingBar({ userName, days, onDaysChange }: GreetingBarProps) {
  const { t, language } = useLanguage();
  const hour = new Date().getHours();
  const greet = t(DASHBOARD_TEXTS[greetingKey(hour)]);
  const subtitle = DASHBOARD_TEXTS.greetingSubtitle[language].replace(
    "{days}",
    String(days),
  );

  return (
    <div className="flex flex-wrap items-start justify-between gap-4 pb-1">
      <div className="min-w-0 max-w-[720px]">
        <p className="m-0 text-[11px] font-semibold tracking-[0.12em] text-slate-400 uppercase">
          {greet}
        </p>
        <h1 className="mt-1.5 mb-0 text-[26px] leading-tight font-semibold tracking-tight text-slate-950">
          {firstName(userName)}
          {t(DASHBOARD_TEXTS.greetingSuffix)}
        </h1>
        <p className="mt-1.5 mb-0 max-w-[480px] text-[14px] leading-snug text-slate-500">
          {subtitle}
        </p>
      </div>

      <SegmentedTabs
        ariaLabel="Period"
        size="sm"
        value={days}
        onChange={onDaysChange}
        className="mt-1.5"
        options={DASHBOARD_PERIODS.map((period) => ({
          value: period.days,
          label: t(period.label),
        }))}
      />
    </div>
  );
}
