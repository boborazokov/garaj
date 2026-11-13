import styled from "styled-components";
import { SHELL_COLORS } from "../../constants";

export const HeaderRoot = styled.header`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  min-height: 56px;
  padding: 8px 22px 4px;
  background: ${SHELL_COLORS.cardBg};
  border-bottom: 1px solid ${SHELL_COLORS.sidebarBorder};

  @media (max-width: 900px) {
    padding: 8px 16px;
  }
`;

export const HeaderLeft = styled.div`
  display: flex;
  align-items: center;
  gap: 10px;
  min-width: 0;
`;

export const MenuButton = styled.button`
  display: none;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 9px;
  background: ${SHELL_COLORS.cardBg};
  color: ${SHELL_COLORS.textSecondary};
  cursor: pointer;

  @media (max-width: 900px) {
    display: inline-flex;
  }
`;

export const CrumbIcon = styled.span`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: ${SHELL_COLORS.textMuted};

  svg {
    width: 16px;
    height: 16px;
  }
`;

export const CrumbGroup = styled.span`
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: ${SHELL_COLORS.textMuted};
`;

export const CrumbDivider = styled.span`
  color: ${SHELL_COLORS.border};
  font-size: 13px;
`;

export const CrumbPage = styled.span`
  font-size: 13px;
  font-weight: 600;
  color: ${SHELL_COLORS.textPrimary};
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
`;

export const HeaderRight = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
`;

export const SearchWrap = styled.div`
  position: relative;
  width: 220px;

  @media (max-width: 720px) {
    display: none;
  }
`;

export const SearchInput = styled.input`
  width: 100%;
  height: 36px;
  padding: 0 44px 0 34px;
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 10px;
  background: ${SHELL_COLORS.cardBg};
  color: ${SHELL_COLORS.textPrimary};
  font-size: 13px;
  outline: none;
  box-sizing: border-box;

  &::placeholder {
    color: ${SHELL_COLORS.textMuted};
  }

  &:focus {
    border-color: #c5d0de;
  }
`;

export const SearchIconWrap = styled.span`
  position: absolute;
  left: 10px;
  top: 50%;
  transform: translateY(-50%);
  color: ${SHELL_COLORS.textMuted};
  display: inline-flex;
  pointer-events: none;
`;

export const SearchKbd = styled.span`
  position: absolute;
  right: 8px;
  top: 50%;
  transform: translateY(-50%);
  padding: 2px 6px;
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 6px;
  font-size: 10px;
  font-weight: 600;
  letter-spacing: 0.02em;
  color: ${SHELL_COLORS.textMuted};
  background: #f8fafc;
  pointer-events: none;
`;

export const SearchResults = styled.ul`
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  right: 0;
  margin: 0;
  padding: 6px;
  list-style: none;
  background: ${SHELL_COLORS.cardBg};
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 10px;
  box-shadow: 0 12px 32px -20px rgba(15, 23, 42, 0.4);
  z-index: 20;
`;

export const SearchResultButton = styled.button<{ $active?: boolean }>`
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  border: 0;
  background: ${({ $active }) => ($active ? SHELL_COLORS.navActiveBg : "transparent")};
  border-radius: 8px;
  padding: 8px 10px;
  font-size: 13px;
  color: ${SHELL_COLORS.textPrimary};
  cursor: pointer;
  text-align: left;

  &:hover {
    background: ${SHELL_COLORS.navHoverBg};
  }
`;

export const SearchEmpty = styled.li`
  padding: 10px;
  font-size: 13px;
  color: ${SHELL_COLORS.textMuted};
`;

export const IconButton = styled.button`
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 9px;
  background: ${SHELL_COLORS.cardBg};
  color: ${SHELL_COLORS.textSecondary};
  cursor: pointer;

  &:hover {
    color: ${SHELL_COLORS.textPrimary};
    border-color: #c5d0de;
  }
`;

export const BellDot = styled.span`
  position: absolute;
  top: 8px;
  right: 8px;
  width: 7px;
  height: 7px;
  border-radius: 999px;
  background: ${SHELL_COLORS.danger};
  border: 1.5px solid ${SHELL_COLORS.cardBg};
`;
