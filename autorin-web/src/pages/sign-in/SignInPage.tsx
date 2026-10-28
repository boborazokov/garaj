import { useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useLazyQuery } from "@apollo/client/react";
import { notification } from "antd";
import { SIGN_IN } from "@/graphql/operations";
import { API_URL } from "@/lib/config";
import {
  isAdmin,
  isModerator,
  clearSession,
  setSession,
  type AuthUser,
} from "@/lib/auth";
import { cleanPhone } from "@/lib/helpers/phone.helpers";
import { useLanguage } from "@/lib/i18n";
import { SIGN_IN_TEXTS } from "./constants";
import type { SignInFormValues } from "./types";
import {
  AsteriskIcon,
  BannerSection,
  LanguageSelect,
  SignInForm,
} from "./components";
import {
  AuthCard,
  PageContainer,
  FormSection,
  FormCenterWrapper,
  FormHeader,
  BrandStarWrapper,
  FormTitle,
  FormSubtitle,
} from "./styles";

export function SignInPage() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const redirect = params.get("redirect") ?? "/admin";
  const { t } = useLanguage();
  const [error, setError] = useState("");

  const [signInQuery, { loading: signInLoading }] = useLazyQuery<
    {
      signIn: {
        token: string;
        refreshToken?: string | null;
        user: AuthUser;
      };
    },
    { data: { phone: string; password: string } }
  >(SIGN_IN, { fetchPolicy: "network-only" });

  const isInvalidCredentialsError = (err: unknown): boolean => {
    if (!err || typeof err !== "object") return false;

    const gqlErr = err as {
      graphQLErrors?: { message?: string; extensions?: { code?: string } }[];
      message?: string;
    };
    const first = gqlErr.graphQLErrors?.[0];
    const code = first?.extensions?.code ?? first?.message ?? gqlErr.message;

    return (
      code === "AUTH_INVALID_CREDENTIALS" ||
      /invalid credentials/i.test(String(code ?? ""))
    );
  };

  const formatApiErrorMessage = (err: unknown): string => {
    if (isInvalidCredentialsError(err)) {
      return t(SIGN_IN_TEXTS.invalidPhoneOrPassword);
    }

    if (err && typeof err === "object" && "graphQLErrors" in err) {
      const gqlErr = err as {
        graphQLErrors?: { message?: string }[];
        message?: string;
      };
      const apiMessage = gqlErr.graphQLErrors?.[0]?.message;
      if (apiMessage && apiMessage !== "AUTH_INVALID_CREDENTIALS") {
        return apiMessage;
      }
      if (gqlErr.message?.includes("Failed to fetch")) {
        return `${t(SIGN_IN_TEXTS.apiUnreachable)} (${API_URL})`;
      }
    }
    return t(SIGN_IN_TEXTS.loginGenericError);
  };

  const handleSignInSubmit = async (values: SignInFormValues) => {
    setError("");

    const digits = cleanPhone(values.phone);
    if (digits.length !== 9) {
      const message = t(SIGN_IN_TEXTS.phoneInvalid);
      setError(message);
      notification.error({
        message: t(SIGN_IN_TEXTS.phoneInvalidTitle),
        description: message,
        placement: "topRight",
      });
      return;
    }

    const formattedPhone = `+998${digits}`;

    try {
      const { data } = await signInQuery({
        variables: {
          data: {
            phone: formattedPhone,
            password: values.password,
          },
        },
      });

      if (!data?.signIn) {
        const message = t(SIGN_IN_TEXTS.invalidPhoneOrPassword);
        setError(message);
        notification.error({
          message: t(SIGN_IN_TEXTS.loginFailedTitle),
          description: message,
          placement: "topRight",
        });
        return;
      }

      const { token, user, refreshToken } = data.signIn;
      setSession(token, user, refreshToken);

      notification.success({
        message: t(SIGN_IN_TEXTS.loginSuccessTitle),
        description: t(SIGN_IN_TEXTS.loginSuccess),
        placement: "topRight",
      });

      if (isAdmin(user)) {
        navigate(redirect.startsWith("/admin") ? redirect : "/admin", {
          replace: true,
        });
      } else if (isModerator(user)) {
        navigate(redirect.startsWith("/moderator") ? redirect : "/moderator", {
          replace: true,
        });
      } else {
        clearSession();
        const message = t(SIGN_IN_TEXTS.accessDenied);
        setError(message);
        notification.error({
          message: t(SIGN_IN_TEXTS.accessDeniedTitle),
          description: message,
          placement: "topRight",
        });
      }
    } catch (err) {
      const apiMessage = formatApiErrorMessage(err);
      setError(apiMessage);
      notification.error({
        message: t(SIGN_IN_TEXTS.loginErrorTitle),
        description: apiMessage,
        placement: "topRight",
      });
    }
  };

  return (
    <PageContainer>
      <AuthCard>
        <BannerSection />
        <FormSection>
          <FormCenterWrapper>
            <FormHeader>
              <BrandStarWrapper>
                <AsteriskIcon size={26} color="#226DF7" />
              </BrandStarWrapper>
              <FormTitle>{t(SIGN_IN_TEXTS.title)}</FormTitle>
              <FormSubtitle>{t(SIGN_IN_TEXTS.subtitle)}</FormSubtitle>
            </FormHeader>

            <SignInForm
              onSubmit={handleSignInSubmit}
              loading={signInLoading}
              error={error}
            />
          </FormCenterWrapper>

          <LanguageSelect />
        </FormSection>
      </AuthCard>
    </PageContainer>
  );
}
