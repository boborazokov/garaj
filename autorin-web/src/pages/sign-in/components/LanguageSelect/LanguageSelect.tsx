import { isLanguageCode, LANGUAGE_OPTIONS, useLanguage } from "@/lib/i18n";
import { SIGN_IN_TEXTS } from "../../constants";
import { LanguagePickerWrap, NativeLanguageSelect } from "./styles";

export function LanguageSelect() {
  const { language, setLanguage, t } = useLanguage();

  return (
    <LanguagePickerWrap>
      <NativeLanguageSelect
        value={language}
        aria-label={t(SIGN_IN_TEXTS.languageAria)}
        onChange={(event) => {
          if (isLanguageCode(event.target.value)) {
            setLanguage(event.target.value);
          }
        }}
      >
        {LANGUAGE_OPTIONS.map((item) => (
          <option key={item.code} value={item.code}>
            {item.label}
          </option>
        ))}
      </NativeLanguageSelect>
    </LanguagePickerWrap>
  );
}
