import { useEffect, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import {
  GET_APP_SETTINGS,
  SET_CONTACT_INFO,
  SET_MODERATION,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { AppSettings } from "@/types";
import { ContactCard, ModerationCard, QuickLinksCard } from "./components";
import { SETTINGS_TEXTS } from "./constants";

export function SettingsPage() {
  const { t } = useLanguage();
  const { data, loading, refetch } = useQuery<{ getAppSettings: AppSettings }>(
    GET_APP_SETTINGS,
    { fetchPolicy: "cache-and-network" },
  );
  const [setModeration, { loading: toggling }] = useMutation(SET_MODERATION);
  const [setContact, { loading: savingContact }] = useMutation(SET_CONTACT_INFO);

  const settings = data?.getAppSettings;
  const enabled = settings?.productModerationEnabled ?? false;

  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [baseline, setBaseline] = useState({ email: "", phone: "" });
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!settings) return;
    const nextEmail = settings.supportEmail ?? "";
    const nextPhone = settings.supportPhone ?? "";
    setEmail(nextEmail);
    setPhone(nextPhone);
    setBaseline({ email: nextEmail, phone: nextPhone });
    setSaved(false);
    setError(null);
  }, [settings]);

  const dirty =
    email.trim() !== baseline.email.trim() ||
    phone.trim() !== baseline.phone.trim();

  async function onToggleModeration() {
    await setModeration({ variables: { enabled: !enabled } });
    await refetch();
  }

  async function onSaveContact() {
    setError(null);
    setSaved(false);
    try {
      await setContact({
        variables: {
          supportEmail: email.trim(),
          supportPhone: phone.trim(),
        },
      });
      await refetch();
      setSaved(true);
    } catch (err) {
      setError(
        err instanceof Error ? err.message : t(SETTINGS_TEXTS.saveError),
      );
    }
  }

  return (
    <div className="flex w-full flex-col gap-3">
      <div className="min-w-0">
        <h1 className="m-0 text-[20px] font-semibold tracking-[-0.3px] text-foreground">
          {t(SETTINGS_TEXTS.title)}
        </h1>
        <p className="mt-1 mb-0 text-[13px] text-muted-foreground">
          {t(SETTINGS_TEXTS.subtitle)}
        </p>
      </div>

      {loading && !settings ? (
        <p className="m-0 rounded-[10px] border border-[#e2e8f0] bg-white px-4 py-8 text-[13px] text-muted-foreground">
          {t(SETTINGS_TEXTS.loading)}
        </p>
      ) : (
        <div className="flex max-w-[720px] flex-col gap-2.5">
          <ModerationCard
            enabled={enabled}
            busy={toggling}
            onToggle={() => {
              void onToggleModeration();
            }}
          />

          <ContactCard
            email={email}
            phone={phone}
            dirty={dirty}
            busy={savingContact}
            saved={saved}
            error={error}
            onEmailChange={(value) => {
              setEmail(value);
              setSaved(false);
            }}
            onPhoneChange={(value) => {
              setPhone(value);
              setSaved(false);
            }}
            onSave={() => {
              void onSaveContact();
            }}
          />

          <QuickLinksCard />
        </div>
      )}
    </div>
  );
}
