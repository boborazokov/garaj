import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { useMutation, useQuery } from "@apollo/client/react";
import {
  ArrowLeft,
  BadgeCheck,
  Send,
  ShieldAlert,
} from "lucide-react";
import {
  ADMIN_SET_USER_VERIFIED,
  CHAT_GET_MESSAGES,
  CHAT_MARK_AS_READ,
  CHAT_SEND_MESSAGE,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PaginatedMessages } from "@/types";
import {
  MESSAGES_COLORS,
  MESSAGES_POLL_MS,
  MESSAGES_TEXTS,
} from "../../constants";
import { buildTimeline, initialsOf, peerOf } from "../../helpers";
import { buildMockMessages } from "../../mock";
import type { ChatMessage, ConversationThreadProps } from "../../types";
import { MessageBubble } from "../MessageBubble";

export function ConversationThread({
  conversation,
  currentUserId,
  mockMode = false,
  onBack,
  onAfterSend,
}: ConversationThreadProps) {
  const { t, language } = useLanguage();
  const peer = peerOf(conversation, currentUserId);
  const profileTo = peer?._id ? `/admin/users/${peer._id}` : null;
  const [draft, setDraft] = useState("");
  const [sending, setSending] = useState(false);
  const [verifiedOverride, setVerifiedOverride] = useState<boolean | null>(null);
  const [mockMessages, setMockMessages] = useState<ChatMessage[]>(() =>
    mockMode ? buildMockMessages(conversation._id, currentUserId) : [],
  );
  const scrollerRef = useRef<HTMLDivElement>(null);
  const lastMessageIdRef = useRef<string | null>(null);

  const messagesQuery = useQuery<{ getMessages: PaginatedMessages }>(
    CHAT_GET_MESSAGES,
    {
      variables: {
        conversationId: conversation._id,
        pagination: { page: 1, limit: 50 },
      },
      pollInterval: mockMode ? 0 : MESSAGES_POLL_MS,
      fetchPolicy: "cache-and-network",
      notifyOnNetworkStatusChange: false,
      skip: mockMode,
    },
  );

  const [sendMessage] = useMutation(CHAT_SEND_MESSAGE);
  const [markAsRead] = useMutation(CHAT_MARK_AS_READ);
  const [setUserVerified, { loading: verifying }] = useMutation<{
    adminSetUserVerified: { _id: string; verified?: boolean | null };
  }>(ADMIN_SET_USER_VERIFIED);

  useEffect(() => {
    setVerifiedOverride(null);
  }, [peer?._id]);

  useEffect(() => {
    if (!mockMode) return;
    setMockMessages(buildMockMessages(conversation._id, currentUserId));
  }, [mockMode, conversation._id, currentUserId]);

  const messages = useMemo(() => {
    if (mockMode) {
      return [...mockMessages].sort(
        (a, b) =>
          new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
      );
    }
    const items = messagesQuery.data?.getMessages.payload ?? [];
    return [...items].sort(
      (a, b) =>
        new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime(),
    );
  }, [mockMode, mockMessages, messagesQuery.data]);

  const timeline = useMemo(
    () => buildTimeline(messages, t, language),
    [messages, t, language],
  );

  useEffect(() => {
    if (mockMode || !conversation._id) return;
    markAsRead({ variables: { conversationId: conversation._id } }).catch(
      () => {},
    );
  }, [mockMode, conversation._id, messages.length, markAsRead]);

  useEffect(() => {
    const last = messages[messages.length - 1];
    if (!last) return;
    if (lastMessageIdRef.current === last._id) return;
    lastMessageIdRef.current = last._id;
    const el = scrollerRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [messages]);

  async function handleSend() {
    const text = draft.trim();
    if (!text || sending) return;
    setSending(true);
    try {
      if (mockMode) {
        const next: ChatMessage = {
          _id: `mock-local-${Date.now()}`,
          text,
          createdAt: new Date().toISOString(),
          sender: {
            _id: currentUserId,
            name: "AutoRin Admin",
            phone: "+998900000000",
            verified: true,
          },
          readBy: [currentUserId],
        };
        setMockMessages((prev) => [...prev, next]);
        setDraft("");
        return;
      }
      await sendMessage({
        variables: {
          data: {
            conversationId: conversation._id,
            text,
          },
        },
      });
      setDraft("");
      await messagesQuery.refetch();
      onAfterSend();
    } catch {
      // Keep composer quiet; admin can retry.
    } finally {
      setSending(false);
    }
  }

  const isVerified = verifiedOverride ?? peer?.verified === true;
  const title = peer?.name?.trim() || peer?.phone || t(MESSAGES_TEXTS.noName);

  async function handleToggleVerified() {
    if (!peer?._id || verifying) return;
    if (mockMode) {
      setVerifiedOverride(!(verifiedOverride ?? peer.verified === true));
      return;
    }
    const next = !isVerified;
    const confirmText = next
      ? `${t(MESSAGES_TEXTS.verifyConfirm)} «${title}»`
      : `${t(MESSAGES_TEXTS.unverifyConfirm)} «${title}»`;
    if (!window.confirm(confirmText)) return;
    setVerifiedOverride(next);
    try {
      await setUserVerified({
        variables: { userId: peer._id, verified: next },
      });
      onAfterSend();
    } catch {
      setVerifiedOverride(!next);
      window.alert(t(MESSAGES_TEXTS.verifyFailed));
    }
  }

  return (
    <div className="flex h-full min-h-0 w-full flex-col" style={{ background: "#ffffff" }}>
      <div
        className="flex items-center gap-3 border-b px-4 py-3"
        style={{ borderColor: MESSAGES_COLORS.border }}
      >
        <button
          type="button"
          onClick={onBack}
          className="flex size-9 items-center justify-center rounded-[9px] border md:hidden"
          style={{
            borderColor: MESSAGES_COLORS.border,
            color: MESSAGES_COLORS.textSecondary,
          }}
        >
          <ArrowLeft className="size-4" />
        </button>

        {profileTo ? (
          <Link
            to={profileTo}
            state={{ peer }}
            className="flex size-10 items-center justify-center rounded-full text-sm font-semibold transition hover:opacity-90"
            style={{
              background: MESSAGES_COLORS.accentSoft,
              color: MESSAGES_COLORS.accent,
            }}
            aria-label={title}
          >
            {initialsOf(peer?.name || peer?.phone)}
          </Link>
        ) : (
          <div
            className="flex size-10 items-center justify-center rounded-full text-sm font-semibold"
            style={{
              background: MESSAGES_COLORS.accentSoft,
              color: MESSAGES_COLORS.accent,
            }}
          >
            {initialsOf(peer?.name || peer?.phone)}
          </div>
        )}

        {profileTo ? (
          <Link
            to={profileTo}
            state={{ peer }}
            className="flex min-w-0 flex-1 flex-col justify-center gap-0 text-left"
          >
            <div
              className="flex items-center gap-1.5 truncate text-[15px] font-semibold leading-none"
              style={{ color: MESSAGES_COLORS.text }}
            >
              <span className="truncate hover:underline">{title}</span>
              {isVerified && (
                <BadgeCheck
                  className="size-4 shrink-0"
                  style={{ color: MESSAGES_COLORS.accent }}
                  aria-label={t(MESSAGES_TEXTS.verified)}
                />
              )}
            </div>
            {peer?.phone && (
              <div
                className="truncate text-[12px] leading-none"
                style={{ color: MESSAGES_COLORS.muted, marginTop: 4 }}
              >
                {peer.phone}
              </div>
            )}
          </Link>
        ) : (
          <div className="flex min-w-0 flex-1 flex-col justify-center gap-0">
            <div
              className="flex items-center gap-1.5 truncate text-[15px] font-semibold leading-none"
              style={{ color: MESSAGES_COLORS.text }}
            >
              <span className="truncate">{title}</span>
            </div>
          </div>
        )}

        {peer?._id && (
          <button
            type="button"
            onClick={() => void handleToggleVerified()}
            disabled={verifying}
            title={
              isVerified
                ? t(MESSAGES_TEXTS.revokeVerified)
                : t(MESSAGES_TEXTS.grantVerified)
            }
            className="hidden shrink-0 items-center gap-1.5 rounded-[9px] border px-3 py-2 text-xs font-semibold transition sm:flex disabled:cursor-not-allowed disabled:opacity-60"
            style={
              isVerified
                ? {
                    borderColor: MESSAGES_COLORS.accentBorder,
                    background: MESSAGES_COLORS.accentSoft,
                    color: MESSAGES_COLORS.accent,
                  }
                : {
                    borderColor: MESSAGES_COLORS.border,
                    background: MESSAGES_COLORS.searchBg,
                    color: MESSAGES_COLORS.textSecondary,
                  }
            }
          >
            {isVerified ? (
              <BadgeCheck className="size-4" />
            ) : (
              <ShieldAlert className="size-4" />
            )}
            <span>
              {verifying
                ? t(MESSAGES_TEXTS.saving)
                : isVerified
                  ? t(MESSAGES_TEXTS.verified)
                  : t(MESSAGES_TEXTS.grantVerified)}
            </span>
          </button>
        )}
      </div>

      <div
        ref={scrollerRef}
        className="min-h-0 flex-1 space-y-3 overflow-y-auto px-4 py-4"
        style={{ background: MESSAGES_COLORS.searchBg }}
      >
        {!mockMode && messagesQuery.loading && messages.length === 0 && (
          <p className="text-center text-xs" style={{ color: MESSAGES_COLORS.muted }}>
            {t(MESSAGES_TEXTS.loading)}
          </p>
        )}
        {(mockMode || !messagesQuery.loading) && messages.length === 0 && (
          <p className="text-center text-xs" style={{ color: MESSAGES_COLORS.muted }}>
            {t(MESSAGES_TEXTS.emptyMessages)}
          </p>
        )}

        {timeline.map((item) => {
          if (item.kind === "day") {
            return (
              <div key={item.key} className="flex justify-center py-1">
                <span
                  className="rounded-full px-3 py-1 text-[11px] font-medium"
                  style={{
                    color: MESSAGES_COLORS.muted,
                    background: "#ffffff",
                    boxShadow: `inset 0 0 0 1px ${MESSAGES_COLORS.border}`,
                  }}
                >
                  {item.label}
                </span>
              </div>
            );
          }

          return (
            <MessageBubble
              key={item.key}
              message={item.message}
              isMine={item.message.sender._id === currentUserId}
            />
          );
        })}
      </div>

      <div
        className="border-t p-3"
        style={{ borderColor: MESSAGES_COLORS.border, background: "#ffffff" }}
      >
        <div className="flex items-end gap-2">
          <textarea
            value={draft}
            onChange={(event) => setDraft(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === "Enter" && !event.shiftKey) {
                event.preventDefault();
                void handleSend();
              }
            }}
            placeholder={t(MESSAGES_TEXTS.draftPlaceholder)}
            rows={1}
            className="min-h-[44px] flex-1 resize-none rounded-[10px] border px-3 py-2.5 text-sm outline-none"
            style={{
              borderColor: MESSAGES_COLORS.border,
              background: MESSAGES_COLORS.searchBg,
              color: MESSAGES_COLORS.text,
            }}
          />
          <button
            type="button"
            onClick={() => void handleSend()}
            disabled={sending || draft.trim().length === 0}
            className="flex size-11 items-center justify-center rounded-[10px] transition disabled:cursor-not-allowed disabled:opacity-40"
            style={{
              background: MESSAGES_COLORS.accent,
              color: "#ffffff",
            }}
          >
            <Send className="size-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
