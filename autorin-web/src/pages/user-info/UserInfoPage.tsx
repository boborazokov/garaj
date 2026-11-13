import { useMemo, useState } from "react";
import { useParams, useLocation } from "react-router-dom";
import { useQuery } from "@apollo/client/react";
import { BarChart3, Package, Wallet } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { ADMIN_LIST_PARTS, ADMIN_LIST_USERS } from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import { cn } from "@/lib/utils";
import type { PaginatedParts, PaginatedUsers } from "@/types";
import {
  UserProductsTable,
  UserProfileCard,
  UserStatsPanel,
  UserWalletCard,
} from "./components";
import {
  USER_INFO_COLORS,
  USER_INFO_PRODUCTS_PAGE_SIZE,
  USER_INFO_TEXTS,
} from "./constants";
import { userFromPeer } from "./helpers";
import {
  getMockProducts,
  getMockUser,
  isMockUserId,
} from "./mock";
import type { UserInfoLocationState, UserInfoTab, UserRow } from "./types";

export function UserInfoPage() {
  const { userId = "" } = useParams<{ userId: string }>();
  const location = useLocation();
  const { t } = useLanguage();
  const locationState = location.state as UserInfoLocationState | null;
  const peer = locationState?.peer;
  const seededUser = locationState?.user ?? null;
  const mock = isMockUserId(userId);
  const [page, setPage] = useState(1);
  const [tab, setTab] = useState<UserInfoTab>("stats");

  const usersQuery = useQuery<{ adminListUsers: PaginatedUsers }>(
    ADMIN_LIST_USERS,
    {
      variables: {
        pagination: { page: 1, limit: 100 },
        search: peer?.phone || peer?.name || seededUser?.phone || seededUser?.name || undefined,
      },
      skip: !userId || mock,
      fetchPolicy: "cache-and-network",
    },
  );

  const partsQuery = useQuery<{ adminListParts: PaginatedParts }>(
    ADMIN_LIST_PARTS,
    {
      variables: {
        pagination: { page, limit: USER_INFO_PRODUCTS_PAGE_SIZE },
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
      if (seededUser && seededUser._id === userId) return seededUser;
      if (peer && peer._id === userId) return userFromPeer(peer);
      return null;
    }
    const list = usersQuery.data?.adminListUsers.payload ?? [];
    const found = list.find((row) => row._id === userId);
    if (found) return found;
    if (seededUser && seededUser._id === userId) return seededUser;
    if (peer && peer._id === userId) return userFromPeer(peer);
    return null;
  }, [userId, mock, usersQuery.data, peer, seededUser]);

  const partsResult = partsQuery.data?.adminListParts;
  const products = useMemo(() => {
    if (mock) return getMockProducts(userId);
    return partsResult?.payload ?? [];
  }, [mock, userId, partsResult]);

  const totalDocs = mock
    ? products.length
    : (partsResult?.totalDocs ?? products.length);
  const totalPages = mock ? 1 : Math.max(1, partsResult?.totalPages ?? 1);
  const activeCount = products.filter((p) => p.status === "ACTIVE").length;
  const viewsCount = products.reduce((sum, p) => sum + (p.viewsCount ?? 0), 0);
  const region = mock ? getMockUser(userId)?.region ?? null : null;

  const loadingUser = !mock && usersQuery.loading && !user;
  const loadingParts = !mock && partsQuery.loading;

  const tabs: { id: UserInfoTab; label: string; icon: LucideIcon }[] = [
    { id: "stats", label: t(USER_INFO_TEXTS.tabStats), icon: BarChart3 },
    { id: "wallet", label: t(USER_INFO_TEXTS.tabWallet), icon: Wallet },
    { id: "products", label: t(USER_INFO_TEXTS.tabProducts), icon: Package },
  ];

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
    <div className="space-y-5">
      <UserProfileCard user={user} />

      <div className="space-y-3.5">
        <div
          role="tablist"
          aria-label={t(USER_INFO_TEXTS.tabsAria)}
          className="inline-flex h-11 items-center gap-1 rounded-[12px] border border-[#e2e8f0] bg-white p-1 shadow-[0_1px_2px_rgba(15,23,42,0.04)]"
        >
          {tabs.map((item) => {
            const active = tab === item.id;
            const Icon = item.icon;
            return (
              <button
                key={item.id}
                type="button"
                role="tab"
                aria-selected={active}
                onClick={() => setTab(item.id)}
                className={cn(
                  "inline-flex h-9 cursor-pointer items-center gap-2 rounded-[9px] px-3.5 text-[13px] font-medium transition-colors",
                  active
                    ? "bg-[#f1f5f9] text-slate-900"
                    : "bg-transparent text-slate-400 hover:text-slate-600",
                )}
              >
                <Icon className="size-4 shrink-0" strokeWidth={1.9} />
                {item.label}
              </button>
            );
          })}
        </div>

        <div role="tabpanel">
          {tab === "stats" ? (
            <UserStatsPanel
              user={user}
              productsCount={totalDocs}
              activeCount={activeCount}
              viewsCount={viewsCount}
              region={region}
            />
          ) : null}

          {tab === "wallet" ? (
            mock ? (
              <p
                className="rounded-[10px] border bg-white px-4 py-8 text-center text-[13px]"
                style={{
                  borderColor: USER_INFO_COLORS.border,
                  color: USER_INFO_COLORS.muted,
                }}
              >
                {t(USER_INFO_TEXTS.walletMockHint)}
              </p>
            ) : (
              <UserWalletCard userId={userId} />
            )
          ) : null}

          {tab === "products" ? (
            <UserProductsTable
              rows={products}
              loading={loadingParts}
              page={partsResult?.page ?? page}
              totalPages={totalPages}
              onPage={setPage}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
}
