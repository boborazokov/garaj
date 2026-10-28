import styled from "styled-components";
import { Link } from "react-router-dom";
import { SIGN_IN_COLORS } from "../../constants";

export const StyledSkipLink = styled(Link)`
  color: ${SIGN_IN_COLORS.textMuted};
  font-size: 13px;
  font-weight: 500;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  transition: all 0.2s ease;
  cursor: pointer;

  &:hover {
    color: ${SIGN_IN_COLORS.primary};
    transform: translateX(2px);
  }
`;
