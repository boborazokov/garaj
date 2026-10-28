import { message } from "antd";
import {
  DividerWrapper,
  DividerLine,
  DividerText,
  SocialRow,
  SocialPill,
} from "./styles";

interface SocialAuthButtonsProps {
  onGoogleClick?: () => void;
}

export function SocialAuthButtons({ onGoogleClick }: SocialAuthButtonsProps) {
  const handleNotice = (provider: string) => {
    message.info(`${provider} orqali kirish tizimi tez orada ishga tushadi`);
  };

  return (
    <>
      <DividerWrapper>
        <DividerLine />
        <DividerText>or continue with</DividerText>
        <DividerLine />
      </DividerWrapper>

      <SocialRow>
        {/* Behance / Telegram */}
        <SocialPill
          type="button"
          onClick={() => handleNotice("Telegram")}
          aria-label="Telegram orqali kirish"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path
              d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8c-.15 1.58-.8 5.42-1.13 7.19-.14.75-.42 1-.68 1.03-.58.05-1.02-.38-1.58-.75-.88-.58-1.38-.94-2.23-1.5-.99-.65-.35-1.01.22-1.59.15-.15 2.71-2.48 2.76-2.69.01-.03.01-.14-.07-.19-.08-.05-.19-.02-.27 0-.12.03-1.99 1.27-5.63 3.72-.53.37-1.01.55-1.44.54-.48-.01-1.39-.27-2.07-.49-.84-.27-1.5-.42-1.44-.88.03-.24.37-.49 1.01-.75 3.96-1.72 6.6-2.86 7.93-3.41 3.77-1.57 4.56-1.84 5.07-1.85.11 0 .37.03.53.17.14.12.18.28.2.45-.02.07-.02.19-.04.29z"
              fill="#226DF7"
            />
          </svg>
        </SocialPill>

        {/* Google */}
        <SocialPill
          type="button"
          onClick={onGoogleClick ?? (() => handleNotice("Google"))}
          aria-label="Google orqali kirish"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
            <path
              d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
              fill="#4285F4"
            />
            <path
              d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
              fill="#34A853"
            />
            <path
              d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
              fill="#FBBC05"
            />
            <path
              d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
              fill="#EA4335"
            />
          </svg>
        </SocialPill>

        {/* Facebook */}
        <SocialPill
          type="button"
          onClick={() => handleNotice("Facebook")}
          aria-label="Facebook orqali kirish"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="#1877F2">
            <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z" />
          </svg>
        </SocialPill>
      </SocialRow>
    </>
  );
}
