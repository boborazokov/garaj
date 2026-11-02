import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useQuery } from "@apollo/client/react";
import { CHAT_GET_CONVERSATIONS } from "../../graphql/operations";
import type { PaginatedConversations } from "../../types";
import { getUser, isAdmin } from "../../lib/auth";
import { AppShell, ADMIN_NAV_GROUPS } from "./app-shell";

export function AdminLayout() {
  const navigate = useNavigate();
  const user = getUser();

  useEffect(() => {
    if (!isAdmin(user)) navigate("/sign-in", { replace: true });
  }, [user, navigate]);

  const unreadQuery = useQuery<{ getConversations: PaginatedConversations }>(
    CHAT_GET_CONVERSATIONS,
    {
      variables: { pagination: { page: 1, limit: 50 } },
      pollInterval: 15_000,
      fetchPolicy: "cache-and-network",
      skip: !isAdmin(user),
      notifyOnNetworkStatusChange: false,
    },
  );

  const messagesUnread = (unreadQuery.data?.getConversations.payload ?? []).reduce(
    (sum, conversation) => sum + (conversation.unread ?? 0),
    0,
  );

  if (!isAdmin(user) || !user) return null;

  return (
    <AppShell
      user={user}
      groups={ADMIN_NAV_GROUPS}
      homeTo="/admin"
      notificationsTo="/admin/messages"
      badges={{ messages: messagesUnread }}
    />
  );
}
