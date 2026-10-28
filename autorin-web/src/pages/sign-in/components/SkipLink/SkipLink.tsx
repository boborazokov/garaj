import type { SkipLinkProps } from "../../types";
import { SIGN_IN_TEXTS } from "../../constants";
import { useLanguage } from "@/lib/i18n";
import { StyledSkipLink } from "./styles";

export function SkipLink({ to = "/admin", onClick }: SkipLinkProps) {
  const { t } = useLanguage();

  return (
    <StyledSkipLink to={to} onClick={onClick}>
      {t(SIGN_IN_TEXTS.skipForNow)}
    </StyledSkipLink>
  );
}
