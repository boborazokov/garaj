import { Link, NavLink } from "react-router-dom";
import styled from "styled-components";
import { SHELL_COLORS } from "../../constants";

export const SidebarRoot = styled.aside<{ $collapsed: boolean; $mobileOpen: boolean }>`
  position: relative;
  display: flex;
  flex-direction: column;
  width: ${({ $collapsed }) => ($collapsed ? "84px" : "260px")};
  flex-shrink: 0;
  height: 100%;
  min-height: 0;
  overflow: hidden;
  background: ${SHELL_COLORS.cardBg};
  border-right: 1px solid ${SHELL_COLORS.sidebarBorder};
  transition: width 0.18s ease;

  @media (max-width: 900px) {
    position: fixed;
    top: 0;
    left: 0;
    bottom: 0;
    z-index: 50;
    width: 260px;
    transform: translateX(${({ $mobileOpen }) => ($mobileOpen ? "0" : "-105%")});
    transition: transform 0.2s ease;
    box-shadow: ${({ $mobileOpen }) =>
      $mobileOpen ? "8px 0 32px rgba(15, 23, 42, 0.12)" : "none"};
  }
`;

export const BrandRow = styled.div<{ $collapsed: boolean }>`
  position: relative;
  display: flex;
  align-items: center;
  justify-content: ${({ $collapsed }) => ($collapsed ? "center" : "space-between")};
  gap: 8px;
  padding: ${({ $collapsed }) => ($collapsed ? "16px 8px 12px" : "16px 14px 12px")};
  flex-shrink: 0;
`;

export const BrandLink = styled(Link)<{ $collapsed: boolean }>`
  display: flex;
  align-items: center;
  gap: 12px;
  min-width: 0;
  padding: 0;
  justify-content: ${({ $collapsed }) => ($collapsed ? "center" : "flex-start")};
  text-decoration: none;
  color: ${SHELL_COLORS.textPrimary};
`;

export const BrandMark = styled.span`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border-radius: 10px;
  overflow: hidden;
  flex-shrink: 0;
`;

export const BrandName = styled.span`
  font-size: 16px;
  font-weight: 650;
  letter-spacing: -0.2px;
  color: ${SHELL_COLORS.textPrimary};
`;

export const NavScroll = styled.nav`
  flex: 1;
  overflow-y: auto;
  padding: 4px 12px 14px;
`;

export const GroupBlock = styled.div`
  & + & {
    margin-top: 12px;
  }
`;

export const GroupLabel = styled.p<{ $collapsed: boolean }>`
  display: ${({ $collapsed }) => ($collapsed ? "none" : "block")};
  margin: 0 0 6px;
  padding: 8px 10px 4px;
  font-size: 12px;
  font-weight: 600;
  letter-spacing: 0.08em;
  text-transform: uppercase;
  color: ${SHELL_COLORS.textMuted};
`;

export const NavItemLink = styled(NavLink)<{ $collapsed: boolean }>`
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 42px;
  padding: ${({ $collapsed }) => ($collapsed ? "0" : "0 12px")};
  justify-content: ${({ $collapsed }) => ($collapsed ? "center" : "flex-start")};
  border-radius: 10px;
  color: ${SHELL_COLORS.textSecondary};
  text-decoration: none;
  font-size: 14.5px;
  font-weight: 500;
  line-height: 1.2;
  transition: background 0.15s ease, color 0.15s ease;

  svg {
    width: 20px;
    height: 20px;
    flex-shrink: 0;
    stroke-width: 1.8;
  }

  &:hover {
    background: ${SHELL_COLORS.navHoverBg};
    color: ${SHELL_COLORS.textPrimary};
  }

  &.active {
    background: ${SHELL_COLORS.navActiveBg};
    color: ${SHELL_COLORS.textPrimary};
    font-weight: 600;
  }
`;

export const NavLabel = styled.span`
  flex: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
`;

export const NavBadge = styled.span`
  min-width: 20px;
  height: 20px;
  padding: 0 6px;
  border-radius: 999px;
  background: ${SHELL_COLORS.avatarBg};
  color: #ffffff;
  font-size: 11px;
  font-weight: 700;
  line-height: 20px;
  text-align: center;
`;

export const SidebarFooter = styled.div<{ $collapsed: boolean }>`
  position: relative;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: ${({ $collapsed }) => ($collapsed ? "12px 8px 14px" : "12px 12px 14px")};
  border-top: 1px solid ${SHELL_COLORS.sidebarBorder};
`;

export const UserButton = styled.button<{ $collapsed: boolean }>`
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  min-width: 0;
  border: 0;
  background: transparent;
  padding: ${({ $collapsed }) => ($collapsed ? "4px" : "6px 8px")};
  justify-content: ${({ $collapsed }) => ($collapsed ? "center" : "flex-start")};
  border-radius: 10px;
  cursor: pointer;
  color: inherit;
  position: relative;

  &:hover {
    background: ${SHELL_COLORS.navHoverBg};
  }
`;

export const Avatar = styled.span`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border-radius: 999px;
  background: ${SHELL_COLORS.avatarBg};
  color: #ffffff;
  font-size: 12px;
  font-weight: 700;
  letter-spacing: 0.02em;
  flex-shrink: 0;
`;

export const UserMeta = styled.span`
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  min-width: 0;
  text-align: left;
`;

export const UserName = styled.span`
  font-size: 14px;
  font-weight: 600;
  color: ${SHELL_COLORS.textPrimary};
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 140px;
`;

export const UserRole = styled.span`
  font-size: 12px;
  color: ${SHELL_COLORS.textMuted};
`;

export const CollapseButton = styled.button<{ $collapsed: boolean }>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  flex-shrink: 0;
  border: 1px solid ${SHELL_COLORS.border};
  background: ${SHELL_COLORS.cardBg};
  border-radius: 8px;
  color: ${SHELL_COLORS.textSecondary};
  cursor: pointer;
  transition: opacity 0.16s ease, color 0.16s ease, border-color 0.16s ease;

  svg {
    width: 16px;
    height: 16px;
  }

  ${({ $collapsed }) =>
    $collapsed &&
    `
    position: absolute;
    top: 10px;
    right: 8px;
    opacity: 0;
    pointer-events: none;
  `}

  ${BrandRow}:hover &,
  ${BrandRow}:focus-within & {
    opacity: 1;
    pointer-events: auto;
  }

  &:hover {
    color: ${SHELL_COLORS.textPrimary};
    border-color: #c5d0de;
  }

  @media (max-width: 900px) {
    display: none;
  }
`;

export const UserMenu = styled.div`
  position: absolute;
  left: 10px;
  bottom: calc(100% + 6px);
  min-width: 168px;
  background: ${SHELL_COLORS.cardBg};
  border: 1px solid ${SHELL_COLORS.border};
  border-radius: 10px;
  box-shadow: 0 10px 30px -18px rgba(15, 23, 42, 0.35);
  overflow: hidden;
  z-index: 3;
`;

export const SignOutButton = styled.button`
  display: flex;
  align-items: center;
  gap: 8px;
  width: 100%;
  border: 0;
  background: transparent;
  padding: 11px 12px;
  font-size: 14px;
  font-weight: 500;
  color: ${SHELL_COLORS.textPrimary};
  cursor: pointer;
  text-align: left;

  &:hover {
    background: ${SHELL_COLORS.navHoverBg};
  }
`;
