import type { AdminWorkshopsSort, ItemStatus, WorkshopRow } from "@/types";

export type ShowFilter = "all" | ItemStatus | "recommended";

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface WorkshopsToolbarProps {
  search: string;
  show: ShowFilter;
  sort: AdminWorkshopsSort;
  categoryId: string;
  status: "" | ItemStatus;
  ownerId: string;
  periodId: string;
  canClear: boolean;
  categories: FilterSelectOption[];
  owners: FilterSelectOption[];
  onSearchChange: (value: string) => void;
  onShowChange: (value: ShowFilter) => void;
  onSortChange: (value: AdminWorkshopsSort) => void;
  onCategoryChange: (value: string) => void;
  onStatusChange: (value: "" | ItemStatus) => void;
  onOwnerChange: (value: string) => void;
  onPeriodChange: (value: string) => void;
  onClear: () => void;
}

export interface WorkshopsTableProps {
  rows: WorkshopRow[];
  loading: boolean;
  selectedIds: string[];
  onToggleAll: (checked: boolean) => void;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (workshop: WorkshopRow) => void;
  onDelete: (workshop: WorkshopRow) => void;
}

export interface WorkshopsPaginationProps {
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

export interface StatsDialogProps {
  workshop: WorkshopRow | null;
  open: boolean;
  onClose: () => void;
}
