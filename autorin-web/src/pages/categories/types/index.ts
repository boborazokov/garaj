import type { RefObject } from "react";
import type { CategoryNames, CategoryRow, CategoryType } from "@/types";

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface CategoryFormState {
  names: CategoryNames;
}

export interface CategoriesToolbarProps {
  search: string;
  type: CategoryType;
  onSearchChange: (value: string) => void;
  onTypeChange: (value: CategoryType) => void;
}

export interface CategoriesTableProps {
  rows: CategoryRow[];
  loading: boolean;
  onEdit: (row: CategoryRow) => void;
  onDelete: (row: CategoryRow) => void;
}

export interface CategoryFormDialogProps {
  open: boolean;
  editing: CategoryRow | null;
  type: CategoryType;
  form: CategoryFormState;
  iconPreview: string | null;
  error: string | null;
  busy: boolean;
  fileInputRef: RefObject<HTMLInputElement | null>;
  onClose: () => void;
  onFormChange: (next: CategoryFormState) => void;
  onPickIcon: (file: File | undefined) => void;
  onClearIcon: () => void;
  onSave: () => void;
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
