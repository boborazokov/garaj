import { useCallback, useEffect, useState } from "react";
import { Outlet } from "react-router-dom";
import { AppHeader } from "./components/AppHeader";
import { Sidebar } from "./components/Sidebar";
import { SIDEBAR_COLLAPSED_KEY, SHELL_TEXTS } from "./constants";
import { useLanguage } from "@/lib/i18n";
import { Backdrop, ContentColumn, MainArea, PageFrame, ShellCard } from "./styles";
import type { AppShellProps } from "./types";

function readCollapsed() {
  if (typeof window === "undefined") return false;
  return window.localStorage.getItem(SIDEBAR_COLLAPSED_KEY) === "1";
}

export function AppShell({
  user,
  groups,
  homeTo,
  notificationsTo,
  badges,
}: AppShellProps) {
  const { t } = useLanguage();
  const [collapsed, setCollapsed] = useState(readCollapsed);
  const [mobileOpen, setMobileOpen] = useState(false);

  const closeMobileNav = useCallback(() => setMobileOpen(false), []);

  const toggleCollapsed = useCallback(() => {
    setCollapsed((current) => {
      const next = !current;
      window.localStorage.setItem(SIDEBAR_COLLAPSED_KEY, next ? "1" : "0");
      return next;
    });
  }, []);

  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 900) setMobileOpen(false);
    };
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  return (
    <PageFrame>
      {mobileOpen && (
        <Backdrop type="button" aria-label={t(SHELL_TEXTS.closeMenuAria)} onClick={closeMobileNav} />
      )}
      <ShellCard>
        <Sidebar
          user={user}
          groups={groups}
          homeTo={homeTo}
          collapsed={collapsed}
          mobileOpen={mobileOpen}
          badges={badges}
          onToggleCollapsed={toggleCollapsed}
          onNavigate={closeMobileNav}
        />
        <ContentColumn>
          <AppHeader
            groups={groups}
            notificationsTo={notificationsTo}
            badges={badges}
            onOpenMobileNav={() => setMobileOpen(true)}
          />
          <MainArea>
            <Outlet />
          </MainArea>
        </ContentColumn>
      </ShellCard>
    </PageFrame>
  );
}
