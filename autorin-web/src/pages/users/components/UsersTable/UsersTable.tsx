import { Link } from "react-router-dom";
import { BadgeCheck, ShieldAlert } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useLanguage } from "@/lib/i18n";
import type { UserRow } from "@/types";
import {
  ROLE_LABELS,
  ROLE_OPTIONS,
  USERS_COLORS,
  USERS_TEXTS,
} from "../../constants";
import { formatJoined, initialsOf } from "../../helpers";
import type { UsersTableProps } from "../../types";

const SKELETON_ROWS = 6;

export function UsersTable({
  rows,
  loading,
  pendingVerified,
  verifying,
  onRoleChange,
  onToggleVerified,
}: UsersTableProps) {
  const { t, language } = useLanguage();
  const showSkeleton = loading && rows.length === 0;

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead>{t(USERS_TEXTS.name)}</TableHead>
            <TableHead>{t(USERS_TEXTS.phone)}</TableHead>
            <TableHead>{t(USERS_TEXTS.role)}</TableHead>
            <TableHead>{t(USERS_TEXTS.verification)}</TableHead>
            <TableHead>{t(USERS_TEXTS.joined)}</TableHead>
            <TableHead className="text-right">{t(USERS_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <UsersSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.length === 0
              ? (
                  <TableRow className="hover:bg-transparent">
                    <TableCell
                      colSpan={6}
                      className="py-12 text-center text-sm text-muted-foreground"
                    >
                      {t(USERS_TEXTS.empty)}
                    </TableCell>
                  </TableRow>
                )
              : rows.map((user) => (
                  <UserRowItem
                    key={user._id}
                    user={user}
                    isVerified={
                      pendingVerified[user._id] ?? user.verified === true
                    }
                    verifying={verifying}
                    language={language}
                    onRoleChange={onRoleChange}
                    onToggleVerified={onToggleVerified}
                  />
                ))}
        </TableBody>
      </Table>
    </div>
  );
}

function UserRowItem({
  user,
  isVerified,
  verifying,
  language,
  onRoleChange,
  onToggleVerified,
}: {
  user: UserRow;
  isVerified: boolean;
  verifying: boolean;
  language: "uz" | "ru" | "en";
  onRoleChange: (user: UserRow, role: string) => void;
  onToggleVerified: (user: UserRow) => void;
}) {
  const { t } = useLanguage();
  const displayName = user.name?.trim() || user.phone || "—";

  return (
    <TableRow>
      <TableCell>
        <Link
          to={`/admin/users/${user._id}`}
          state={{
            peer: {
              _id: user._id,
              name: user.name,
              phone: user.phone,
              verified: user.verified,
            },
          }}
          className="inline-flex min-w-0 max-w-[240px] items-center gap-2.5 rounded-md outline-none hover:opacity-80 focus-visible:ring-2 focus-visible:ring-[#226DF7]/30"
        >
          <span
            className="flex size-9 shrink-0 items-center justify-center rounded-full text-[12px] font-semibold"
            style={{
              background: USERS_COLORS.accentSoft,
              color: USERS_COLORS.accent,
            }}
          >
            {initialsOf(displayName)}
          </span>
          <span className="min-w-0">
            <span className="flex items-center gap-1.5">
              <span className="truncate text-[13px] font-medium text-foreground">
                {displayName}
              </span>
              {isVerified ? (
                <BadgeCheck className="size-3.5 shrink-0 text-sky-500" />
              ) : null}
            </span>
          </span>
        </Link>
      </TableCell>

      <TableCell className="text-[13px] text-muted-foreground">
        {user.phone || "—"}
      </TableCell>

      <TableCell>
        <Select
          value={user.role}
          onValueChange={(value) => onRoleChange(user, value)}
        >
          <SelectTrigger className="h-8 w-[140px] text-[12px]">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            {ROLE_OPTIONS.map((role) => (
              <SelectItem key={role} value={role}>
                {t(ROLE_LABELS[role])}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </TableCell>

      <TableCell>
        <span
          className="inline-flex h-7 items-center gap-1.5 rounded-full px-2.5 text-[12px] font-semibold"
          style={
            isVerified
              ? { background: "#ecfdf5", color: "#059669" }
              : { background: "#fff7ed", color: "#c2410c", border: "1px solid #fdba74" }
          }
        >
          {isVerified ? (
            <BadgeCheck className="size-3.5 shrink-0" />
          ) : (
            <ShieldAlert className="size-3.5 shrink-0" />
          )}
          {isVerified
            ? t(USERS_TEXTS.verified)
            : t(USERS_TEXTS.notVerified)}
        </span>
      </TableCell>

      <TableCell className="text-[13px] text-muted-foreground">
        {formatJoined(user.createdAt, language)}
      </TableCell>

      <TableCell className="text-right">
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={verifying}
          className="h-8 gap-1.5 px-2.5 text-[12px]"
          onClick={() => onToggleVerified(user)}
        >
          {isVerified ? (
            <ShieldAlert className="size-3.5" />
          ) : (
            <BadgeCheck className="size-3.5" />
          )}
          {isVerified ? t(USERS_TEXTS.unverify) : t(USERS_TEXTS.verify)}
        </Button>
      </TableCell>
    </TableRow>
  );
}

function UsersSkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
      <TableCell>
        <div className="flex items-center gap-2.5">
          <Skeleton className="size-9 rounded-full" />
          <Skeleton className="h-4 w-28" />
        </div>
      </TableCell>
      <TableCell>
        <Skeleton className="h-4 w-24" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-8 w-[140px] rounded-md" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-7 w-28 rounded-full" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-4 w-20" />
      </TableCell>
      <TableCell>
        <Skeleton className="ml-auto h-8 w-24 rounded-md" />
      </TableCell>
    </TableRow>
  );
}
