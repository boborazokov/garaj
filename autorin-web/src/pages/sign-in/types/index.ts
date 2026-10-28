import type { LocalizedText } from "@/lib/i18n";

export interface SignInFormValues {
  phone: string;
  password: string;
}

export interface SliderItem {
  id: number;
  image: string;
  alt: LocalizedText;
  subtitle: LocalizedText;
  title: LocalizedText;
  description: LocalizedText;
}

export interface GoogleButtonProps {
  onClick?: () => void;
  loading?: boolean;
}

export interface SkipLinkProps {
  to?: string;
  onClick?: () => void;
}
