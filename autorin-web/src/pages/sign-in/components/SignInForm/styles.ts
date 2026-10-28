import styled from "styled-components";
import { Input, Button } from "antd";
import { Link } from "react-router-dom";
import { SIGN_IN_COLORS } from "../../constants";
import { PhoneInput } from "../phone-formatter";

export const FormContainer = styled.div`
  width: 100%;
  --ant-form-vertical-label-padding: 0 0 4px;
  --ant-form-label-height: auto;
  --ant-form-item-margin-bottom: 14px;

  .ant-form-item {
    margin-bottom: 14px;
  }

  .ant-form-item-label {
    padding-bottom: 4px !important;
  }

  .ant-form-item-label > label {
    height: auto !important;
    width: 100%;
    font-size: 13.5px;
    font-weight: 600;
    color: ${SIGN_IN_COLORS.textPrimary};
  }

  .ant-form-item-explain,
  .ant-form-item-additional {
    min-height: 0 !important;
    margin-top: 2px;
  }

  .ant-form-item-explain-error {
    font-size: 12px;
    line-height: 1.3;
    margin-top: 2px;
    color: ${SIGN_IN_COLORS.error};
  }
`;

export const FieldLabel = styled.label`
  display: block;
  font-size: 13.5px;
  font-weight: 600;
  color: ${SIGN_IN_COLORS.textPrimary};
  margin: 0;
  user-select: none;
`;

export const StyledTextInput = styled(Input)`
  height: 45px;
  border-radius: 10px;
  border: 1.5px solid ${SIGN_IN_COLORS.inputBorder};
  padding: 0 14px;
  font-size: 14px;
  color: ${SIGN_IN_COLORS.textPrimary};
  background-color: #ffffff;
  transition: all 0.2s ease;

  &::placeholder {
    color: ${SIGN_IN_COLORS.textMuted};
  }

  &:hover {
    border-color: ${SIGN_IN_COLORS.primaryBorder};
  }

  &:focus {
    border-color: ${SIGN_IN_COLORS.primary};
    box-shadow: 0 0 0 3px rgba(34, 109, 247, 0.15);
  }
`;

export const StyledPhoneInput = styled(PhoneInput)`
  height: 45px;
  border-radius: 10px;
  border: 1.5px solid ${SIGN_IN_COLORS.inputBorder};
  padding: 0 14px;
  font-size: 14px;
  color: ${SIGN_IN_COLORS.textPrimary};
  background-color: #ffffff;
  transition: all 0.2s ease;

  .ant-input {
    font-size: 14px;
    color: ${SIGN_IN_COLORS.textPrimary};

    &::placeholder {
      color: ${SIGN_IN_COLORS.textMuted};
    }
  }

  &:hover {
    border-color: ${SIGN_IN_COLORS.primaryBorder};
  }

  &:focus,
  &.ant-input-affix-wrapper-focused {
    border-color: ${SIGN_IN_COLORS.primary};
    box-shadow: 0 0 0 3px rgba(34, 109, 247, 0.15);
  }
`;

export const StyledPasswordInput = styled(Input.Password)`
  height: 45px;
  border-radius: 10px;
  border: 1.5px solid ${SIGN_IN_COLORS.inputBorder};
  padding: 0 14px;
  font-size: 14px;
  color: ${SIGN_IN_COLORS.textPrimary};
  background-color: #ffffff;
  transition: all 0.2s ease;

  .ant-input {
    font-size: 14px;
    color: ${SIGN_IN_COLORS.textPrimary};

    &::placeholder {
      color: ${SIGN_IN_COLORS.textMuted};
    }
  }

  &:hover {
    border-color: ${SIGN_IN_COLORS.primaryBorder};
  }

  &:focus,
  &.ant-input-affix-wrapper-focused {
    border-color: ${SIGN_IN_COLORS.primary};
    box-shadow: 0 0 0 3px rgba(34, 109, 247, 0.15);
  }

  .ant-input-suffix {
    color: ${SIGN_IN_COLORS.textMuted};
    cursor: pointer;

    &:hover {
      color: ${SIGN_IN_COLORS.primary};
    }
  }
`;

export const ForgotPasswordRow = styled.div`
  display: flex;
  justify-content: flex-end;
  margin: 0 0 12px;
`;

export const ForgotPasswordLink = styled.button`
  background: none;
  border: none;
  padding: 0;
  font-size: 12px;
  font-weight: 500;
  color: ${SIGN_IN_COLORS.primary};
  cursor: pointer;
  transition: color 0.2s ease;
  user-select: none;

  &:hover {
    color: ${SIGN_IN_COLORS.primaryHover};
    text-decoration: underline;
  }
`;

export const SubmitButton = styled(Button)`
  width: 100%;
  height: 47px;
  border-radius: 12px;
  border: none;
  background-color: ${SIGN_IN_COLORS.primary} !important;
  color: #ffffff !important;
  font-size: 15px;
  font-weight: 600;
  margin-top: 6px;
  cursor: pointer;
  transition: background-color 0.18s ease, box-shadow 0.18s ease, transform 0.18s ease;
  box-shadow: 0 8px 18px -10px rgba(34, 109, 247, 0.7);

  &:hover {
    background-color: ${SIGN_IN_COLORS.primaryHover} !important;
    box-shadow: 0 10px 20px -10px rgba(34, 109, 247, 0.8);
    transform: translateY(-1px);
  }

  &:active {
    background-color: ${SIGN_IN_COLORS.primaryActive} !important;
    transform: translateY(0);
    box-shadow: none;
  }

  &:disabled,
  &[disabled] {
    opacity: 0.65;
    cursor: not-allowed;
    transform: none;
    background-color: ${SIGN_IN_COLORS.primary} !important;
    color: #ffffff !important;
    box-shadow: none;
  }
`;

export const SignupPrompt = styled.div`
  text-align: center;
  font-size: 13px;
  color: #64748b;
  margin-top: 16px;
  user-select: none;
`;

export const SignupLink = styled(Link)`
  color: ${SIGN_IN_COLORS.primary};
  font-weight: 600;
  margin-left: 5px;
  text-decoration: none;
  transition: color 0.2s ease;

  &:hover {
    color: ${SIGN_IN_COLORS.primaryHover};
    text-decoration: underline;
  }
`;

export const ErrorAlert = styled.div`
  background-color: #fef2f2;
  border: 1px solid #fee2e2;
  color: #b91c1c;
  padding: 10px 14px;
  border-radius: 10px;
  font-size: 13px;
  margin-bottom: 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  animation: fadeIn 0.2s ease-in-out;

  @keyframes fadeIn {
    from {
      opacity: 0;
      transform: translateY(-4px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
`;
