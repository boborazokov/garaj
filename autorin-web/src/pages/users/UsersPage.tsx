import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import {
  ADMIN_LIST_USERS,
  ADMIN_SET_USER_ROLE,
  ADMIN_SET_USER_VERIFIED,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PaginatedUsers, UserRow } from "@/types";
import {
  ConfirmDialog,
  UsersPagination,
  UsersTable,
  UsersToolbar,
} from "./components";
import { USERS_PAGE_SIZE, USERS_TEXTS } from "./constants";
import { matchesUserFilters } from "./helpers";
import type { RoleFilter, VerifiedFilter } from "./types";

export function UsersPage() {
  const { t } = useLanguage();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [role, setRole] = useState<RoleFilter>("");
  const [verified, setVerified] = useState<VerifiedFilter>("");
  const [page, setPage] = useState(1);
  const [pendingVerified, setPendingVerified] = useState<Record<string, boolean>>(
    {},
  );
  const [pendingUser, setPendingUser] = useState<UserRow | null>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    setPage(1);
  }, [search, role, verified]);

  const canClear =
    Boolean(searchInput.trim()) || Boolean(role) || Boolean(verified);

  const { data, loading, refetch } = useQuery<{ adminListUsers: PaginatedUsers }>(
    ADMIN_LIST_USERS,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        pagination: { page, limit: USERS_PAGE_SIZE },
        search: search || undefined,
      },
    },
  );

  const [setRoleMutation] = useMutation(ADMIN_SET_USER_ROLE);
  const [setVerifiedMutation, { loading: verifying }] = useMutation<{
    adminSetUserVerified: { _id: string; verified?: boolean | null };
  }>(ADMIN_SET_USER_VERIFIED);

  const result = data?.adminListUsers;
  const rows = useMemo(
    () =>
      (result?.payload ?? []).filter((user) =>
        matchesUserFilters(user, role, verified),
      ),
    [result?.payload, role, verified],
  );

  async function changeRole(user: UserRow, nextRole: string) {
    try {
      await setRoleMutation({ variables: { userId: user._id, role: nextRole } });
      await refetch();
    } catch {
      window.alert(t(USERS_TEXTS.roleFailed));
    }
  }

  function requestToggleVerified(user: UserRow) {
    setPendingUser(user);
  }

  async function confirmToggleVerified() {
    if (!pendingUser) return;
    const user = pendingUser;
    const isVerifiedNow =
      pendingVerified[user._id] ?? user.verified === true;
    const next = !isVerifiedNow;
    setPendingVerified((prev) => ({ ...prev, [user._id]: next }));
    try {
      await setVerifiedMutation({
        variables: { userId: user._id, verified: next },
      });
      await refetch();
      setPendingVerified((prev) => {
        const { [user._id]: _drop, ...rest } = prev;
        return rest;
      });
      setPendingUser(null);
    } catch {
      setPendingVerified((prev) => {
        const { [user._id]: _drop, ...rest } = prev;
        return rest;
      });
      window.alert(t(USERS_TEXTS.verifyFailed));
    }
  }

  function clearFilters() {
    setSearchInput("");
    setSearch("");
    setRole("");
    setVerified("");
  }

  const pendingIsVerified =
    pendingUser != null
      ? (pendingVerified[pendingUser._id] ?? pendingUser.verified === true)
      : false;

  return (
    <div className="flex flex-col gap-2.5">
      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <UsersToolbar
          search={searchInput}
          role={role}
          verified={verified}
          canClear={canClear}
          onSearchChange={setSearchInput}
          onRoleChange={setRole}
          onVerifiedChange={setVerified}
          onClear={clearFilters}
        />

        <UsersTable
          rows={rows}
          loading={loading}
          pendingVerified={pendingVerified}
          verifying={verifying}
          onRoleChange={(user, nextRole) => {
            void changeRole(user, nextRole);
          }}
          onToggleVerified={requestToggleVerified}
        />

        <UsersPagination
          page={result?.page ?? page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <ConfirmDialog
        open={Boolean(pendingUser)}
        title={t(USERS_TEXTS.confirmVerifyTitle)}
        message={
          pendingIsVerified
            ? t(USERS_TEXTS.confirmUnverify)
            : t(USERS_TEXTS.confirmVerify)
        }
        confirmLabel={t(USERS_TEXTS.confirm)}
        busy={verifying}
        onCancel={() => setPendingUser(null)}
        onConfirm={() => {
          void confirmToggleVerified();
        }}
      />
    </div>
  );
}
