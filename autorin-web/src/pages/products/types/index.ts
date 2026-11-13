import type {
  AdminPartsSort,
  ItemStatus,
  Part,
  PromotionPlan,
  PromotionPlanPrice,
} from "@/types";

export type ShowFilter = "all" | ItemStatus | "recommended";
export type PeriodFilterId = string;

export interface ProductsFiltersState {
  search: string;
  show: ShowFilter;
  sort: AdminPartsSort;
  categoryId: string;
  status: "" | ItemStatus;
  sellerId: string;
  periodId: PeriodFilterId;
}

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface ProductsToolbarProps {
  search: string;
  show: ShowFilter;
  sort: AdminPartsSort;
  categoryId: string;
  status: "" | ItemStatus;
  sellerId: string;
  periodId: string;
  canClear: boolean;
  categories: FilterSelectOption[];
  sellers: FilterSelectOption[];
  onSearchChange: (value: string) => void;
  onShowChange: (value: ShowFilter) => void;
  onSortChange: (value: AdminPartsSort) => void;
  onCategoryChange: (value: string) => void;
  onStatusChange: (value: "" | ItemStatus) => void;
  onSellerChange: (value: string) => void;
  onPeriodChange: (value: string) => void;
  onClear: () => void;
}

export interface ProductsTableProps {
  rows: Part[];
  loading: boolean;
  selectedIds: string[];
  onToggleAll: (checked: boolean) => void;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (part: Part) => void;
  onDelete: (part: Part) => void;
  onOpenStats: (part: Part) => void;
}

export interface StatsDialogProps {
  part: Part | null;
  open: boolean;
  onClose: () => void;
}

export interface ProductsPaginationProps {
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

export interface PromotePlanDialogProps {
  open: boolean;
  partName?: string;
  prices: PromotionPlanPrice[];
  busy?: boolean;
  error?: string | null;
  onCancel: () => void;
  onConfirm: (plan: PromotionPlan) => void;
}

