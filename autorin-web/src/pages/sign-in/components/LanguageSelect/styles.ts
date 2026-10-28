import styled from "styled-components";
import { SIGN_IN_COLORS } from "../../constants";

export const LanguagePickerWrap = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  width: 100%;
  margin-top: auto;
  padding-top: 16px;
`;

export const NativeLanguageSelect = styled.select`
  appearance: none;
  padding: 6px 28px 6px 12px;
  border: 1px solid #dbe3ee;
  border-radius: 8px;
  background-color: #ffffff;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M1 1l4 4 4-4' stroke='%23888' stroke-width='1.4' fill='none'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 10px center;
  font-size: 13px;
  font-weight: 500;
  line-height: 1.4;
  color: #64748b;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover,
  &:focus {
    border-color: #c5d0de;
    outline: none;
    color: ${SIGN_IN_COLORS.textPrimary};
  }
`;

export const HelpButton = styled.button`
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 12px;
  border: 1px solid #dbe3ee;
  border-radius: 8px;
  background: #ffffff;
  font-size: 13px;
  font-weight: 500;
  line-height: 1.4;
  color: #64748b;
  cursor: pointer;
  transition: all 0.2s ease;

  &:hover,
  &:focus {
    border-color: #c5d0de;
    outline: none;
    color: ${SIGN_IN_COLORS.textPrimary};
  }
`;
