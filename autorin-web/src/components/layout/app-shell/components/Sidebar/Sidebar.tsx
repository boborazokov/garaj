import { useEffect, useRef, useState } from "react";
import { useNavigate } from "react-router-dom";
import { LogOut, PanelLeftClose, PanelLeftOpen } from "lucide-react";
import { BrandLogo } from "@/components/brand";
import { clearSession, type AuthUser } from "@/lib/auth";
import { useLanguage } from "@/lib/i18n";
import { SHELL_TEXTS } from "../../constants";
import type { AppNavGroup, NavBadgeKey } from "../../types";
import {
  Avatar,
  BrandLink,
  BrandMark,
  BrandName,
  BrandRow,
  CollapseButton,
  GroupBlock,
  GroupLabel,
  NavBadge,
  NavItemLink,
  NavLabel,
  NavScroll,
  SidebarFooter,
  SidebarRoot,
  SignOutButton,
  UserButton,
  UserMenu,
  UserMeta,
  UserName,
  UserRole,
} from "./styles";

interface SidebarProps {
  user: AuthUser;
  groups: AppNavGroup[];
  homeTo: string;
  collapsed: boolean;
  mobileOpen: boolean;
  badges?: Partial<Record<NavBadgeKey, number>>;
  onToggleCollapsed: () => void;
  onNavigate: () => void;
}

function getInitials(name: string) {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length >= 2) {
    return `${parts[0][0] ?? ""}${parts[1][0] ?? ""}`.toUpperCase();
  }
  return name.slice(0, 2).toUpperCase() || "G";
}

export function Sidebar({
  user,
  groups,
  homeTo,
  collapsed,
  mobileOpen,
  badges,
  onToggleCollapsed,
  onNavigate,
}: SidebarProps) {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [menuOpen, setMenuOpen] = useState(false);
  const footerRef = useRef<HTMLDivElement>(null);

  const compact = collapsed && !mobileOpen;
  const roleLabel =
    user.role === "MODERATOR" ? t(SHELL_TEXTS.moderator) : t(SHELL_TEXTS.administrator);

  useEffect(() => {
    setMenuOpen(false);
  }, [collapsed, mobileOpen]);

  useEffect(() => {
    const handlePointer = (event: MouseEvent) => {
      if (!footerRef.current?.contains(event.target as Node)) {
        setMenuOpen(false);
      }
    };
    document.addEventListener("mousedown", handlePointer);
    return () => document.removeEventListener("mousedown", handlePointer);
  }, []);

  const handleSignOut = () => {
    clearSession();
    navigate("/sign-in");
  };

  return (
    <SidebarRoot $collapsed={collapsed} $mobileOpen={mobileOpen}>
      <BrandRow $collapsed={compact}>
        <BrandLink to={homeTo} $collapsed={compact} onClick={onNavigate}>
          <BrandMark>
            <BrandLogo size={38} />
          </BrandMark>
          {!compact && <BrandName>{t(SHELL_TEXTS.brand)}</BrandName>}
        </BrandLink>

        <CollapseButton
          type="button"
          $collapsed={compact}
          onClick={(event) => {
            onToggleCollapsed();
            event.currentTarget.blur();
          }}
          aria-label={collapsed ? t(SHELL_TEXTS.expandAria) : t(SHELL_TEXTS.collapseAria)}
        >
          {collapsed ? <PanelLeftOpen /> : <PanelLeftClose />}
        </CollapseButton>
      </BrandRow>

      <NavScroll>
        {groups.map((group) => (
          <GroupBlock key={group.id}>
            <GroupLabel $collapsed={compact}>{t(group.label)}</GroupLabel>
            {group.items.map(({ to, label, icon: Icon, end, badgeKey }) => {
              const badge = badgeKey ? (badges?.[badgeKey] ?? 0) : 0;
              return (
                <NavItemLink
                  key={to}
                  to={to}
                  end={end}
                  $collapsed={compact}
                  title={compact ? t(label) : undefined}
                  onClick={onNavigate}
                >
                  <Icon />
                  {!compact && <NavLabel>{t(label)}</NavLabel>}
                  {!compact && badge > 0 && (
                    <NavBadge>{badge > 99 ? "99+" : badge}</NavBadge>
                  )}
                </NavItemLink>
              );
            })}
          </GroupBlock>
        ))}
      </NavScroll>

      <SidebarFooter ref={footerRef} $collapsed={compact}>
        {menuOpen && (
          <UserMenu>
            <SignOutButton type="button" onClick={handleSignOut}>
              <LogOut size={16} />
              {t(SHELL_TEXTS.signOut)}
            </SignOutButton>
          </UserMenu>
        )}

        <UserButton
          type="button"
          $collapsed={compact}
          onClick={() => setMenuOpen((open) => !open)}
          aria-haspopup="menu"
          aria-expanded={menuOpen}
        >
          <Avatar>{getInitials(user.name)}</Avatar>
          {!compact && (
            <UserMeta>
              <UserName>{user.name}</UserName>
              <UserRole>{roleLabel}</UserRole>
            </UserMeta>
          )}
        </UserButton>
      </SidebarFooter>
    </SidebarRoot>
  );
}
