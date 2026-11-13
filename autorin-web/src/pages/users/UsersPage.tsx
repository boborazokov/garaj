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
  RoleConfirmDialog,
  UsersPagination,
  UsersTable,
  UsersToolbar,
} from "./components";
import { ROLE_LABELS, USERS_PAGE_SIZE, USERS_TEXTS } from "./constants";
import type { UserRoleOption } from "./constants";
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
  const [pendingRole, setPendingRole] = useState<{
    user: UserRow;
    role: string;
  } | null>(null);
  const [roleBusy, setRoleBusy] = useState(false);
  const [roleError, setRoleError] = useState<string | null>(null);

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

  function requestRoleChange(user: UserRow, nextRole: string) {
    if (user.role === nextRole) return;
    setRoleError(null);
    setPendingRole({ user, role: nextRole });
  }

  async function confirmRoleChange(password: string) {
    if (!pendingRole) return;
    const trimmed = password.trim();
    if (!trimmed) {
      setRoleError(t(USERS_TEXTS.passwordRequired));
      return;
    }
    setRoleBusy(true);
    setRoleError(null);
    try {
      await setRoleMutation({
        variables: {
          userId: pendingRole.user._id,
          role: pendingRole.role,
          password: trimmed,
        },
      });
      await refetch();
      setPendingRole(null);
    } catch (err) {
      const msg = err instanceof Error ? err.message : "";
      const lower = msg.toLowerCase();
      setRoleError(
        lower.includes("password") || lower.includes("parol")
          ? t(USERS_TEXTS.passwordWrong)
          : t(USERS_TEXTS.roleFailed),
      );
    } finally {
      setRoleBusy(false);
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

  const pendingRoleLabel =
    pendingRole && pendingRole.role in ROLE_LABELS
      ? t(ROLE_LABELS[pendingRole.role as UserRoleOption])
      : pendingRole?.role ?? "";

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
          onRoleChange={requestRoleChange}
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

      <RoleConfirmDialog
        open={Boolean(pendingRole)}
        title={t(USERS_TEXTS.confirmRoleTitle)}
        message={`${t(USERS_TEXTS.confirmRoleMessage)}${
          pendingRole
            ? ` (${pendingRole.user.name} → ${pendingRoleLabel})`
            : ""
        }`}
        busy={roleBusy}
        error={roleError}
        onCancel={() => {
          if (!roleBusy) {
            setPendingRole(null);
            setRoleError(null);
          }
        }}
        onConfirm={(password) => {
          void confirmRoleChange(password);
        }}
      />
    </div>
  );
}
