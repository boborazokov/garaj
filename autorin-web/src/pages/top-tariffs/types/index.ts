import type { PromotionPlan, PromotionPlanPrice } from "@/types";

export interface TariffFormState {
  plan: PromotionPlan;
  baseAmount: number;
  days: number;
  discountPercent: number;
}

export interface TopTariffsTableProps {
  rows: PromotionPlanPrice[];
  loading: boolean;
  busy: boolean;
  onEdit: (row: PromotionPlanPrice) => void;
  onDelete: (row: PromotionPlanPrice) => void;
}

export interface TariffFormDialogProps {
  open: boolean;
  editing: boolean;
  form: TariffFormState;
  error: string | null;
  busy: boolean;
  planOptions: PromotionPlan[];
  onClose: () => void;
  onFormChange: (next: TariffFormState) => void;
  onSave: () => void;
}

export interface ConfirmDialogProps {
  open: boolean;
  title: string;
  message: string;
  confirmLabel: string;
  busy: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}
