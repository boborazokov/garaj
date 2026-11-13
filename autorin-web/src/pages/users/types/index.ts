import type { UserRow } from "@/types";
import type { UserRoleOption } from "../constants";

export type { UserRow };

export type RoleFilter = "" | UserRoleOption;
export type VerifiedFilter = "" | "verified" | "unverified";

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface UsersToolbarProps {
  search: string;
  role: RoleFilter;
  verified: VerifiedFilter;
  canClear: boolean;
  onSearchChange: (value: string) => void;
  onRoleChange: (value: RoleFilter) => void;
  onVerifiedChange: (value: VerifiedFilter) => void;
  onClear: () => void;
}

export interface UsersTableProps {
  rows: UserRow[];
  loading: boolean;
  pendingVerified: Record<string, boolean>;
  verifying: boolean;
  onRoleChange: (user: UserRow, role: string) => void;
  onToggleVerified: (user: UserRow) => void;
}

export interface UsersPaginationProps {
  page: number;
  totalPages: number;
  onPage: (page: number) => void;
}

export interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmLabel: string;
  busy?: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}

export interface RoleConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  busy?: boolean;
  error?: string | null;
  onCancel: () => void;
  onConfirm: (password: string) => void;
}
