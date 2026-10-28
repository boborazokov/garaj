import styled from "styled-components";
import { SIGN_IN_COLORS } from "../../constants";

export const StyledGoogleButton = styled.button`
  width: 100%;
  height: 44px;
  background-color: #ffffff;
  border: 1.5px solid ${SIGN_IN_COLORS.primaryBorder};
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  color: ${SIGN_IN_COLORS.primary};
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  outline: none;
  user-select: none;

  &:hover {
    background-color: ${SIGN_IN_COLORS.primaryLight};
    border-color: ${SIGN_IN_COLORS.primary};
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(34, 109, 247, 0.12);
  }

  &:active {
    transform: translateY(0);
    background-color: rgba(34, 109, 247, 0.12);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
  }
`;

export const GoogleIconWrapper = styled.span`
  display: flex;
  align-items: center;
  justify-content: center;
  width: 18px;
  height: 18px;
`;
