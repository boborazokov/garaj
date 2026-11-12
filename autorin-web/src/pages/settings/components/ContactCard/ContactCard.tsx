import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import { SETTINGS_TEXTS } from "../../constants";
import type { ContactCardProps } from "../../types";

export function ContactCard({
  email,
  phone,
  dirty,
  busy,
  saved,
  error,
  onEmailChange,
  onPhoneChange,
  onSave,
}: ContactCardProps) {
  const { t } = useLanguage();

  return (
    <section className="overflow-hidden rounded-[10px] border border-[#e2e8f0] bg-white">
      <div className="border-b border-[#eef0f3] px-4 py-3">
        <h2 className="m-0 text-[14px] font-semibold text-foreground">
          {t(SETTINGS_TEXTS.contactsTitle)}
        </h2>
        <p className="mt-1 mb-0 text-[12px] text-muted-foreground">
          {t(SETTINGS_TEXTS.contactsSubtitle)}
        </p>
      </div>

      <form
        className="flex flex-col gap-3.5 px-4 py-3.5"
        onSubmit={(event) => {
          event.preventDefault();
          onSave();
        }}
      >
        <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
          <label className="flex flex-col gap-1.5 text-[13px]">
            <span className="text-muted-foreground">{t(SETTINGS_TEXTS.email)}</span>
            <Input
              type="email"
              className="h-11"
              value={email}
              disabled={busy}
              placeholder={t(SETTINGS_TEXTS.emailPlaceholder)}
              onChange={(event) => onEmailChange(event.target.value)}
              autoComplete="email"
            />
          </label>

          <label className="flex flex-col gap-1.5 text-[13px]">
            <span className="text-muted-foreground">{t(SETTINGS_TEXTS.phone)}</span>
            <Input
              type="tel"
              className="h-11"
              value={phone}
              disabled={busy}
              placeholder={t(SETTINGS_TEXTS.phonePlaceholder)}
              onChange={(event) => onPhoneChange(event.target.value)}
              autoComplete="tel"
            />
          </label>
        </div>

        {error ? (
          <p className="m-0 text-[12px] text-red-600">{error}</p>
        ) : null}
        {!error && saved && !dirty ? (
          <p className="m-0 text-[12px] text-emerald-600">
            {t(SETTINGS_TEXTS.saved)}
          </p>
        ) : null}

        <div className="flex justify-start pt-0.5">
          <Button type="submit" className="h-11 min-w-[112px]" disabled={busy || !dirty}>
            {busy ? t(SETTINGS_TEXTS.saving) : t(SETTINGS_TEXTS.save)}
          </Button>
        </div>
      </form>
    </section>
  );
}
