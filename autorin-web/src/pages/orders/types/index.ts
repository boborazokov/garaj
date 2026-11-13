import type { AdminOrdersSort, OrderRow, OrderStatus } from "@/types";

export type ShowFilter = "all" | OrderStatus | "recommended";

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface OrdersToolbarProps {
  search: string;
  show: ShowFilter;
  sort: AdminOrdersSort;
  categoryId: string;
  status: "" | OrderStatus;
  authorId: string;
  periodId: string;
  canClear: boolean;
  categories: FilterSelectOption[];
  authors: FilterSelectOption[];
  onSearchChange: (value: string) => void;
  onShowChange: (value: ShowFilter) => void;
  onSortChange: (value: AdminOrdersSort) => void;
  onCategoryChange: (value: string) => void;
  onStatusChange: (value: "" | OrderStatus) => void;
  onAuthorChange: (value: string) => void;
  onPeriodChange: (value: string) => void;
  onClear: () => void;
}

export interface OrdersTableProps {
  rows: OrderRow[];
  loading: boolean;
  selectedIds: string[];
  onToggleAll: (checked: boolean) => void;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (order: OrderRow) => void;
  onOffers: (order: OrderRow) => void;
  onClose: (order: OrderRow) => void;
  onReopen: (order: OrderRow) => void;
  onDelete: (order: OrderRow) => void;
  onOpenStats: (order: OrderRow) => void;
}

export interface StatsDialogProps {
  order: OrderRow | null;
  open: boolean;
  onClose: () => void;
}

export interface OrdersPaginationProps {
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

export interface OffersDialogProps {
  order: OrderRow | null;
  open: boolean;
  onClose: () => void;
}
