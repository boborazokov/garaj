import { Form, notification } from "antd";
import type { SignInFormValues } from "../../types";
import { SIGN_IN_TEXTS } from "../../constants";
import { cleanPhone } from "@/lib/helpers/phone.helpers";
import { useLanguage } from "@/lib/i18n";
import {
  FormContainer,
  StyledPhoneInput,
  StyledPasswordInput,
  ForgotPasswordRow,
  ForgotPasswordLink,
  SubmitButton,
  ErrorAlert,
} from "./styles";

interface SignInFormProps {
  onSubmit: (values: SignInFormValues) => Promise<void>;
  loading?: boolean;
  error?: string;
  onForgotPassword?: () => void;
  onGoogleClick?: () => void;
}

export function SignInForm({
  onSubmit,
  loading = false,
  error,
  onForgotPassword,
}: SignInFormProps) {
  const [form] = Form.useForm<SignInFormValues>();
  const { t } = useLanguage();

  const handleFinish = async (values: SignInFormValues) => {
    await onSubmit(values);
  };

  const handleForgotClick = () => {
    if (onForgotPassword) {
      onForgotPassword();
    } else {
      notification.info({
        message: t(SIGN_IN_TEXTS.forgotPasswordTitle),
        description: t(SIGN_IN_TEXTS.forgotPasswordDescription),
        placement: "topRight",
      });
    }
  };

  return (
    <FormContainer>
      {error && <ErrorAlert>{error}</ErrorAlert>}

      <Form<SignInFormValues>
        form={form}
        name="signInForm"
        layout="vertical"
        onFinish={handleFinish}
        requiredMark={false}
        autoComplete="off"
      >
        <Form.Item
          name="phone"
          label={t(SIGN_IN_TEXTS.phoneLabel)}
          getValueFromEvent={(event) => cleanPhone(event.target.value)}
          normalize={(value) => cleanPhone(value ?? "")}
          rules={[
            {
              required: true,
              message: t(SIGN_IN_TEXTS.phoneRequired),
            },
            {
              validator(_, value) {
                const digits = cleanPhone(value ?? "");

                if (!digits || digits.length === 9) {
                  return Promise.resolve();
                }
                return Promise.reject(new Error(t(SIGN_IN_TEXTS.phoneInvalid)));
              },
            },
          ]}
        >
          <StyledPhoneInput
            id="phone"
            placeholder={t(SIGN_IN_TEXTS.phonePlaceholder)}
            disabled={loading}
          />
        </Form.Item>

        <Form.Item
          name="password"
          label={t(SIGN_IN_TEXTS.passwordLabel)}
          style={{ marginBottom: 6 }}
          rules={[
            {
              required: true,
              message: t(SIGN_IN_TEXTS.passwordRequired),
            },
          ]}
        >
          <StyledPasswordInput
            id="password"
            placeholder={t(SIGN_IN_TEXTS.passwordPlaceholder)}
            disabled={loading}
          />
        </Form.Item>

        <ForgotPasswordRow>
          <ForgotPasswordLink type="button" onClick={handleForgotClick}>
            {t(SIGN_IN_TEXTS.forgotPassword)}
          </ForgotPasswordLink>
        </ForgotPasswordRow>

        <Form.Item style={{ marginBottom: 0 }}>
          <SubmitButton
            type="primary"
            htmlType="submit"
            loading={loading}
            disabled={loading}
          >
            {loading ? t(SIGN_IN_TEXTS.submitting) : t(SIGN_IN_TEXTS.submitButton)}
          </SubmitButton>
        </Form.Item>
      </Form>
    </FormContainer>
  );
}
