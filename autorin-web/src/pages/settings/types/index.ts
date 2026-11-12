export interface ModerationCardProps {
  enabled: boolean;
  busy: boolean;
  onToggle: () => void;
}

export interface ContactCardProps {
  email: string;
  phone: string;
  dirty: boolean;
  busy: boolean;
  saved: boolean;
  error: string | null;
  onEmailChange: (value: string) => void;
  onPhoneChange: (value: string) => void;
  onSave: () => void;
}
