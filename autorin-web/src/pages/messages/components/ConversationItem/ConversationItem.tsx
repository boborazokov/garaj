import { BadgeCheck, CheckCheck, Pin, PinOff } from "lucide-react";
import { Link } from "react-router-dom";
import { useLanguage } from "@/lib/i18n";
import { MESSAGES_COLORS, MESSAGES_TEXTS } from "../../constants";
import {
  formatRelative,
  initialsOf,
  renderLastMessagePreview,
} from "../../helpers";
import type { ConversationItemProps } from "../../types";

export function ConversationItem({
  conversation,
  peer,
  active,
  pinned,
  onSelect,
  onTogglePin,
}: ConversationItemProps) {
  const { t, language } = useLanguage();
  const unread = conversation.unread ?? 0;
  const subtitle = renderLastMessagePreview(
    conversation.lastMessageText?.trim() ?? "",
    t,
  );
  const title = peer?.name?.trim() || peer?.phone || t(MESSAGES_TEXTS.noName);
  const mineLast =
    conversation.lastMessageSender &&
    peer &&
    conversation.lastMessageSender !== peer._id;
  const profileTo = peer?._id ? `/admin/users/${peer._id}` : null;

  return (
    <div
      className="group relative"
      style={{
        background: active ? MESSAGES_COLORS.accentSoft : "transparent",
      }}
    >
      <div className="flex w-full items-start gap-3 px-3 py-2.5">
        {profileTo ? (
          <Link
            to={profileTo}
            state={{ peer }}
            className="flex size-10 shrink-0 items-center justify-center rounded-full text-sm font-semibold"
            style={{
              background: active ? MESSAGES_COLORS.accent : MESSAGES_COLORS.searchBg,
              color: active ? "#ffffff" : MESSAGES_COLORS.accent,
              boxShadow: active
                ? undefined
                : `inset 0 0 0 1px ${MESSAGES_COLORS.border}`,
            }}
            aria-label={title}
          >
            {initialsOf(peer?.name || peer?.phone)}
          </Link>
        ) : (
          <div
            className="flex size-10 shrink-0 items-center justify-center rounded-full text-sm font-semibold"
            style={{
              background: MESSAGES_COLORS.searchBg,
              color: MESSAGES_COLORS.accent,
              boxShadow: `inset 0 0 0 1px ${MESSAGES_COLORS.border}`,
            }}
          >
            {initialsOf(peer?.name || peer?.phone)}
          </div>
        )}

        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between gap-2">
            <div
              className="flex min-w-0 items-center gap-1 truncate text-[13px] font-semibold"
              style={{ color: MESSAGES_COLORS.text }}
            >
              {profileTo ? (
                <Link
                  to={profileTo}
                  state={{ peer }}
                  className="truncate hover:underline"
                >
                  {title}
                </Link>
              ) : (
                <span className="truncate">{title}</span>
              )}
              {peer?.verified && (
                <BadgeCheck
                  className="size-3.5 shrink-0"
                  style={{ color: MESSAGES_COLORS.accent }}
                  aria-label={t(MESSAGES_TEXTS.verified)}
                />
              )}
            </div>
            <button
              type="button"
              onClick={onSelect}
              className="shrink-0 text-[11px]"
              style={{ color: MESSAGES_COLORS.muted }}
            >
              {formatRelative(conversation.lastMessageAt, language)}
            </button>
          </div>

          <button
            type="button"
            onClick={onSelect}
            className="mt-0.5 flex w-full items-center justify-between gap-2 text-left"
          >
            <p
              className={`flex min-w-0 items-center gap-1 truncate text-[12px] ${
                unread > 0 ? "font-semibold" : ""
              }`}
              style={{
                color: unread > 0 ? MESSAGES_COLORS.text : MESSAGES_COLORS.muted,
              }}
            >
              {mineLast && unread === 0 && (
                <CheckCheck
                  className="size-3.5 shrink-0"
                  style={{ color: MESSAGES_COLORS.accent }}
                />
              )}
              <span className="truncate">{subtitle}</span>
            </p>
            {unread > 0 && (
              <span
                className="inline-flex h-[18px] min-w-[18px] shrink-0 items-center justify-center rounded-full px-1 text-[10px] font-bold"
                style={{
                  background: MESSAGES_COLORS.unreadBadge,
                  color: "#ffffff",
                }}
              >
                {unread > 99 ? "99+" : unread}
              </span>
            )}
          </button>
        </div>
      </div>

      <button
        type="button"
        onClick={onTogglePin}
        title={pinned ? t(MESSAGES_TEXTS.unpin) : t(MESSAGES_TEXTS.pin)}
        className="absolute top-2 right-2 flex size-7 items-center justify-center rounded-md opacity-0 transition group-hover:opacity-100"
        style={{
          color: pinned ? MESSAGES_COLORS.accent : MESSAGES_COLORS.muted,
          background: "#ffffff",
          boxShadow: `inset 0 0 0 1px ${MESSAGES_COLORS.border}`,
        }}
      >
        {pinned ? <PinOff className="size-3.5" /> : <Pin className="size-3.5" />}
      </button>
    </div>
  );
}
