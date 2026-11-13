import { useEffect, useMemo, useRef, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import { Bell, Menu, Search } from "lucide-react";
import { LanguageSelect } from "@/components/language-select";
import { useLanguage } from "@/lib/i18n";
import { SHELL_TEXTS } from "../../constants";
import type { AppNavGroup, AppNavItem, NavBadgeKey } from "../../types";
import {
  BellDot,
  CrumbDivider,
  CrumbGroup,
  CrumbIcon,
  CrumbPage,
  HeaderLeft,
  HeaderRight,
  HeaderRoot,
  IconButton,
  MenuButton,
  SearchEmpty,
  SearchIconWrap,
  SearchInput,
  SearchKbd,
  SearchResultButton,
  SearchResults,
  SearchWrap,
} from "./styles";

interface AppHeaderProps {
  groups: AppNavGroup[];
  notificationsTo?: string;
  badges?: Partial<Record<NavBadgeKey, number>>;
  onOpenMobileNav: () => void;
}

function findActive(
  groups: AppNavGroup[],
  pathname: string,
): { group: AppNavGroup; item: AppNavItem } | null {
  let match: { group: AppNavGroup; item: AppNavItem } | null = null;

  for (const group of groups) {
    for (const item of group.items) {
      const isMatch = item.end
        ? pathname === item.to
        : pathname === item.to || pathname.startsWith(`${item.to}/`);

      if (isMatch && (!match || item.to.length > match.item.to.length)) {
        match = { group, item };
      }
    }
  }

  return match;
}

export function AppHeader({
  groups,
  notificationsTo,
  badges,
  onOpenMobileNav,
}: AppHeaderProps) {
  const location = useLocation();
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState(false);
  const [activeIndex, setActiveIndex] = useState(0);
  const searchRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const active = findActive(groups, location.pathname);
  const unread = badges?.messages ?? 0;
  const ActiveIcon = active?.item.icon;

  const results = useMemo(() => {
    const needle = query.trim().toLowerCase();
    const items = groups.flatMap((group) =>
      group.items.map((item) => ({ group, item })),
    );
    if (!needle) return items.slice(0, 6);
    return items.filter(
      ({ group, item }) =>
        t(item.label).toLowerCase().includes(needle) ||
        t(group.label).toLowerCase().includes(needle),
    );
  }, [groups, query, t]);

  useEffect(() => {
    const handlePointer = (event: MouseEvent) => {
      if (!searchRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    };
    document.addEventListener("mousedown", handlePointer);
    return () => document.removeEventListener("mousedown", handlePointer);
  }, []);

  useEffect(() => {
    const handleKey = (event: KeyboardEvent) => {
      if ((event.ctrlKey || event.metaKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        inputRef.current?.focus();
        setOpen(true);
      }
    };
    document.addEventListener("keydown", handleKey);
    return () => document.removeEventListener("keydown", handleKey);
  }, []);

  useEffect(() => {
    setActiveIndex(0);
  }, [query]);

  const goTo = (to: string) => {
    navigate(to);
    setQuery("");
    setOpen(false);
  };

  return (
    <HeaderRoot>
      <HeaderLeft>
        <MenuButton type="button" onClick={onOpenMobileNav} aria-label={t(SHELL_TEXTS.menuAria)}>
          <Menu size={16} />
        </MenuButton>
        {active && ActiveIcon && (
          <>
            <CrumbIcon>
              <ActiveIcon />
            </CrumbIcon>
            <CrumbGroup>{t(active.group.label)}</CrumbGroup>
            <CrumbDivider>/</CrumbDivider>
            <CrumbPage>{t(active.item.label)}</CrumbPage>
          </>
        )}
      </HeaderLeft>

      <HeaderRight>
        <SearchWrap ref={searchRef}>
          <SearchIconWrap>
            <Search size={14} />
          </SearchIconWrap>
          <SearchInput
            ref={inputRef}
            value={query}
            placeholder={t(SHELL_TEXTS.searchPlaceholder)}
            aria-label={t(SHELL_TEXTS.searchAria)}
            onChange={(event) => {
              setQuery(event.target.value);
              setOpen(true);
            }}
            onFocus={() => setOpen(true)}
            onKeyDown={(event) => {
              if (event.key === "ArrowDown") {
                event.preventDefault();
                setActiveIndex((index) => Math.min(index + 1, Math.max(results.length - 1, 0)));
              } else if (event.key === "ArrowUp") {
                event.preventDefault();
                setActiveIndex((index) => Math.max(index - 1, 0));
              } else if (event.key === "Enter" && results[activeIndex]) {
                event.preventDefault();
                goTo(results[activeIndex].item.to);
              } else if (event.key === "Escape") {
                setOpen(false);
                inputRef.current?.blur();
              }
            }}
          />
          <SearchKbd>Ctrl K</SearchKbd>
          {open && (
            <SearchResults>
              {results.length === 0 ? (
                <SearchEmpty>{t(SHELL_TEXTS.searchEmpty)}</SearchEmpty>
              ) : (
                results.map(({ item }, index) => {
                  const Icon = item.icon;
                  return (
                    <li key={item.to}>
                      <SearchResultButton
                        type="button"
                        $active={index === activeIndex}
                        onMouseEnter={() => setActiveIndex(index)}
                        onClick={() => goTo(item.to)}
                      >
                        <Icon size={14} />
                        {t(item.label)}
                      </SearchResultButton>
                    </li>
                  );
                })
              )}
            </SearchResults>
          )}
        </SearchWrap>

        <LanguageSelect
          compact
          ariaLabel={t(SHELL_TEXTS.languageAria)}
        />

        {notificationsTo && (
          <IconButton
            type="button"
            aria-label={t(SHELL_TEXTS.notificationsAria)}
            onClick={() => navigate(notificationsTo)}
          >
            <Bell size={16} />
            {unread > 0 && <BellDot />}
          </IconButton>
        )}
      </HeaderRight>
    </HeaderRoot>
  );
}
