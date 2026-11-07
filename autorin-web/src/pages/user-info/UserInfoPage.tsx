import { useMemo } from "react";
import { useParams, useLocation } from "react-router-dom";
import { useQuery } from "@apollo/client/react";
import { ADMIN_LIST_PARTS, ADMIN_LIST_USERS } from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PaginatedParts, PaginatedUsers } from "@/types";
import { UserProductsTable, UserProfileCard } from "./components";
import { USER_INFO_COLORS, USER_INFO_TEXTS } from "./constants";
import { userFromPeer } from "./helpers";
import {
  getMockProducts,
  getMockUser,
  isMockUserId,
} from "./mock";
import type { UserInfoLocationState, UserRow } from "./types";

export function UserInfoPage() {
  const { userId = "" } = useParams<{ userId: string }>();
  const location = useLocation();
  const { t } = useLanguage();
  const peer = (location.state as UserInfoLocationState | null)?.peer;
  const mock = isMockUserId(userId);

  const usersQuery = useQuery<{ adminListUsers: PaginatedUsers }>(
    ADMIN_LIST_USERS,
    {
      variables: {
        pagination: { page: 1, limit: 50 },
        search: peer?.phone || peer?.name || undefined,
      },
      skip: !userId || mock,
      fetchPolicy: "cache-and-network",
    },
  );

  const partsQuery = useQuery<{ adminListParts: PaginatedParts }>(
    ADMIN_LIST_PARTS,
    {
      variables: {
        pagination: { page: 1, limit: 50 },
        sellerId: userId,
        sort: "NEWEST",
      },
      skip: !userId || mock,
      fetchPolicy: "cache-and-network",
    },
  );

  const user = useMemo<UserRow | null>(() => {
    if (!userId) return null;
    if (mock) {
      const fromMock = getMockUser(userId);
      if (fromMock) return fromMock;
      if (peer && peer._id === userId) return userFromPeer(peer);
      return null;
    }
    const list = usersQuery.data?.adminListUsers.payload ?? [];
    const found = list.find((row) => row._id === userId);
    if (found) return found;
    if (peer && peer._id === userId) return userFromPeer(peer);
    return null;
  }, [userId, mock, usersQuery.data, peer]);

  const products = useMemo(() => {
    if (mock) return getMockProducts(userId);
    return partsQuery.data?.adminListParts.payload ?? [];
  }, [mock, userId, partsQuery.data]);

  const activeCount = products.filter((p) => p.status === "ACTIVE").length;
  const viewsCount = products.reduce((sum, p) => sum + (p.viewsCount ?? 0), 0);
  const region = mock ? getMockUser(userId)?.region ?? null : null;

  const loadingUser = !mock && usersQuery.loading && !user;
  const loadingParts = !mock && partsQuery.loading;

  if (!userId) {
    return (
      <p className="text-sm" style={{ color: USER_INFO_COLORS.muted }}>
        {t(USER_INFO_TEXTS.notFound)}
      </p>
    );
  }

  if (loadingUser) {
    return (
      <p className="text-sm" style={{ color: USER_INFO_COLORS.muted }}>
        {t(USER_INFO_TEXTS.loading)}
      </p>
    );
  }

  if (!user) {
    return (
      <p className="text-sm" style={{ color: USER_INFO_COLORS.muted }}>
        {t(USER_INFO_TEXTS.notFound)}
      </p>
    );
  }

  return (
    <div className="space-y-3">
      <UserProfileCard
        user={user}
        productsCount={products.length}
        activeCount={activeCount}
        viewsCount={viewsCount}
        region={region}
      />
      <UserProductsTable rows={products} loading={loadingParts} />
    </div>
  );
}
