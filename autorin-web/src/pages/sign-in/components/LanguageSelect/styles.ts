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
