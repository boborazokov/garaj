import { LanguageSelect as SharedLanguageSelect } from "@/components/language-select";
import { useLanguage } from "@/lib/i18n";
import { SIGN_IN_TEXTS } from "../../constants";
import { LanguagePickerWrap } from "./styles";

export function LanguageSelect() {
  const { t } = useLanguage();

  return (
    <LanguagePickerWrap>
      <SharedLanguageSelect ariaLabel={t(SIGN_IN_TEXTS.languageAria)} />
    </LanguagePickerWrap>
  );
}
