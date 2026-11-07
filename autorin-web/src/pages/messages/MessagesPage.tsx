import { useMemo, useState } from "react";
import { useQuery } from "@apollo/client/react";
import { CHAT_GET_CONVERSATIONS } from "@/graphql/operations";
import { getUser } from "@/lib/auth";
import { useLanguage } from "@/lib/i18n";
import type { PaginatedConversations } from "@/types";
import {
  ConversationSidebar,
  ConversationThread,
} from "./components";
import {
  CONVERSATIONS_POLL_MS,
  MESSAGES_COLORS,
  MESSAGES_TEXTS,
  USE_MOCK_MESSAGES_FALLBACK,
} from "./constants";
import { readPinnedIds, writePinnedIds } from "./helpers";
import {
  buildMockConversations,
  DEFAULT_MOCK_PINNED,
  isMockConversationId,
} from "./mock";

export function MessagesPage() {
  const { t } = useLanguage();
  const me = getUser();
  const currentUserId = me?._id || "mock-admin";

  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [pinnedIds, setPinnedIds] = useState<Set<string>>(() => {
    const stored = readPinnedIds();
    if (stored.size > 0) return stored;
    return new Set(DEFAULT_MOCK_PINNED);
  });

  const conversationsQuery = useQuery<{
    getConversations: PaginatedConversations;
  }>(CHAT_GET_CONVERSATIONS, {
    variables: { pagination: { page: 1, limit: 50 } },
    pollInterval: CONVERSATIONS_POLL_MS,
    fetchPolicy: "cache-and-network",
    notifyOnNetworkStatusChange: false,
  });

  const usingMock = useMemo(() => {
    if (!USE_MOCK_MESSAGES_FALLBACK) return false;
    const list = conversationsQuery.data?.getConversations.payload ?? [];
    return !conversationsQuery.loading && list.length === 0;
  }, [conversationsQuery.data, conversationsQuery.loading]);

  const conversations = useMemo(() => {
    const list = conversationsQuery.data?.getConversations.payload ?? [];
    const source =
      list.length > 0
        ? list
        : USE_MOCK_MESSAGES_FALLBACK && !conversationsQuery.loading
          ? buildMockConversations(currentUserId)
          : [];
    return [...source].sort((a, b) => {
      const at = a.lastMessageAt ? new Date(a.lastMessageAt).getTime() : 0;
      const bt = b.lastMessageAt ? new Date(b.lastMessageAt).getTime() : 0;
      return bt - at;
    });
  }, [conversationsQuery.data, conversationsQuery.loading, currentUserId]);

  const selected = useMemo(
    () => conversations.find((c) => c._id === selectedId) ?? null,
    [conversations, selectedId],
  );

  function handleTogglePin(id: string) {
    setPinnedIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      writePinnedIds(next);
      return next;
    });
  }

  return (
    <div
      className="-mx-1 flex h-[calc(100vh-96px)] min-h-[560px] overflow-hidden rounded-[10px] border md:-mx-0"
      style={{
        borderColor: MESSAGES_COLORS.border,
        background: "#ffffff",
      }}
    >
      <div
        className={`h-full w-full shrink-0 md:w-[340px] lg:w-[360px] ${
          selected ? "hidden md:flex" : "flex"
        }`}
      >
        <ConversationSidebar
          conversations={conversations}
          currentUserId={currentUserId}
          selectedId={selectedId}
          pinnedIds={pinnedIds}
          loading={conversationsQuery.loading && conversations.length === 0}
          search={search}
          onSearchChange={setSearch}
          onSelect={setSelectedId}
          onTogglePin={handleTogglePin}
          onRefresh={() => void conversationsQuery.refetch()}
        />
      </div>

      <div
        className={`min-h-0 min-w-0 flex-1 ${selected ? "flex" : "hidden md:flex"}`}
      >
        {selected ? (
          <ConversationThread
            key={selected._id}
            conversation={selected}
            currentUserId={currentUserId}
            mockMode={usingMock || isMockConversationId(selected._id)}
            onBack={() => setSelectedId(null)}
            onAfterSend={() => void conversationsQuery.refetch()}
          />
        ) : (
          <div
            className="flex w-full flex-col items-center justify-center px-6 text-center"
            style={{ background: MESSAGES_COLORS.searchBg }}
          >
            <p
              className="max-w-sm text-sm"
              style={{ color: MESSAGES_COLORS.muted }}
            >
              {t(MESSAGES_TEXTS.emptyThread)}
            </p>
          </div>
        )}
      </div>
    </div>
  );
}

/** @deprecated Use MessagesPage — kept for existing imports */
export const AdminMessagesPage = MessagesPage;
