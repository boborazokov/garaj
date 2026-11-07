import type { ReactNode } from "react";
import { MessageSquare, Pin, Search, SquarePen } from "lucide-react";
import { useLanguage } from "@/lib/i18n";
import { MESSAGES_COLORS, MESSAGES_TEXTS } from "../../constants";
import { peerOf } from "../../helpers";
import type { ConversationSidebarProps } from "../../types";
import { ConversationItem } from "../ConversationItem";

export function ConversationSidebar({
  conversations,
  currentUserId,
  selectedId,
  pinnedIds,
  loading,
  search,
  onSearchChange,
  onSelect,
  onTogglePin,
  onRefresh,
}: ConversationSidebarProps) {
  const { t } = useLanguage();

  const query = search.trim().toLowerCase();
  const filtered = query
    ? conversations.filter((conversation) => {
        const peer = peerOf(conversation, currentUserId);
        const haystack = [
          peer?.name,
          peer?.phone,
          conversation.lastMessageText,
        ]
          .filter(Boolean)
          .join(" ")
          .toLowerCase();
        return haystack.includes(query);
      })
    : conversations;

  const pinned = filtered.filter((c) => pinnedIds.has(c._id));
  const rest = filtered.filter((c) => !pinnedIds.has(c._id));

  return (
    <aside
      className="flex h-full min-h-0 w-full flex-col border-r"
      style={{ borderColor: MESSAGES_COLORS.border, background: "#ffffff" }}
    >
      <div className="flex items-center justify-between gap-2 px-4 pt-4 pb-2">
        <h1
          className="text-[20px] font-bold tracking-tight"
          style={{ color: MESSAGES_COLORS.text }}
        >
          {t(MESSAGES_TEXTS.title)}
        </h1>
        <button
          type="button"
          onClick={onRefresh}
          aria-label={t(MESSAGES_TEXTS.newMessageAria)}
          className="flex size-9 items-center justify-center rounded-[9px] transition hover:opacity-90"
          style={{
            background: MESSAGES_COLORS.accent,
            color: "#ffffff",
          }}
        >
          <SquarePen className="size-4" />
        </button>
      </div>

      <div className="px-4 pb-3">
        <label className="relative block">
          <Search
            className="pointer-events-none absolute top-1/2 left-3 size-[15px] -translate-y-1/2"
            style={{ color: MESSAGES_COLORS.muted }}
          />
          <input
            value={search}
            onChange={(event) => onSearchChange(event.target.value)}
            placeholder={t(MESSAGES_TEXTS.searchPlaceholder)}
            className="h-11 w-full rounded-[10px] border pr-3 pl-9 text-[13px] outline-none"
            style={{
              borderColor: MESSAGES_COLORS.border,
              background: MESSAGES_COLORS.searchBg,
              color: MESSAGES_COLORS.text,
            }}
          />
        </label>
      </div>

      <div className="min-h-0 flex-1 overflow-y-auto">
        {loading && filtered.length === 0 && (
          <p
            className="px-4 py-6 text-sm"
            style={{ color: MESSAGES_COLORS.muted }}
          >
            {t(MESSAGES_TEXTS.loading)}
          </p>
        )}

        {!loading && filtered.length === 0 && (
          <div className="flex flex-col items-center gap-2 px-6 py-14 text-center">
            <MessageSquare
              className="size-8"
              style={{ color: MESSAGES_COLORS.muted }}
            />
            <p
              className="text-sm font-medium"
              style={{ color: MESSAGES_COLORS.text }}
            >
              {t(MESSAGES_TEXTS.emptyList)}
            </p>
            <p className="text-xs" style={{ color: MESSAGES_COLORS.muted }}>
              {t(MESSAGES_TEXTS.emptyListHint)}
            </p>
          </div>
        )}

        {pinned.length > 0 && (
          <Section
            label={t(MESSAGES_TEXTS.pinned)}
            icon={<Pin className="size-3" />}
          >
            {pinned.map((conversation) => (
              <ConversationItem
                key={conversation._id}
                conversation={conversation}
                peer={peerOf(conversation, currentUserId)}
                active={conversation._id === selectedId}
                pinned
                onSelect={() => onSelect(conversation._id)}
                onTogglePin={() => onTogglePin(conversation._id)}
              />
            ))}
          </Section>
        )}

        {rest.length > 0 && (
          <Section
            label={t(MESSAGES_TEXTS.all)}
            icon={<Pin className="size-3 opacity-40" />}
          >
            {rest.map((conversation) => (
              <ConversationItem
                key={conversation._id}
                conversation={conversation}
                peer={peerOf(conversation, currentUserId)}
                active={conversation._id === selectedId}
                pinned={false}
                onSelect={() => onSelect(conversation._id)}
                onTogglePin={() => onTogglePin(conversation._id)}
              />
            ))}
          </Section>
        )}
      </div>
    </aside>
  );
}

function Section({
  label,
  icon,
  children,
}: {
  label: string;
  icon: ReactNode;
  children: ReactNode;
}) {
  return (
    <div className="pb-2">
      <div
        className="flex items-center gap-1.5 px-4 pt-2 pb-3 text-[11px] font-semibold tracking-wide uppercase"
        style={{ color: MESSAGES_COLORS.muted }}
      >
        {icon}
        <span>{label}</span>
      </div>
      <div className="mt-0.5">{children}</div>
    </div>
  );
}
