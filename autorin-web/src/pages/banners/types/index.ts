import type { RefObject } from "react";
import type {
  AdvertisementRow,
  AdvertisementStatus,
  CategoryType,
} from "@/types";
import type { DurationPreset } from "../constants";

export interface FilterSelectOption {
  value: string;
  label: string;
}

export interface BannerFormState {
  title: string;
  link: string;
  bannerImageUrl: string;
  startsAt: string;
  endsAt: string;
  duration: DurationPreset;
  status: "ACTIVE" | "PAUSED";
}

export interface BannersToolbarProps {
  search: string;
  placement: CategoryType;
  status: "" | AdvertisementStatus;
  canClear: boolean;
  onSearchChange: (value: string) => void;
  onPlacementChange: (value: CategoryType) => void;
  onStatusChange: (value: "" | AdvertisementStatus) => void;
  onClear: () => void;
}

export interface BannersTableProps {
  rows: AdvertisementRow[];
  loading: boolean;
  onEdit: (row: AdvertisementRow) => void;
  onDelete: (row: AdvertisementRow) => void;
  onStats: (row: AdvertisementRow) => void;
}

export interface BannerFormDialogProps {
  open: boolean;
  editing: AdvertisementRow | null;
  placement: CategoryType;
  form: BannerFormState;
  imagePreview: string | null;
  error: string | null;
  busy: boolean;
  fileInputRef: RefObject<HTMLInputElement | null>;
  onClose: () => void;
  onFormChange: (next: BannerFormState) => void;
  onPickImage: (file: File | undefined) => void;
  onClearImage: () => void;
  onSave: () => void;
}

export interface StatsDialogProps {
  banner: AdvertisementRow | null;
  open: boolean;
  onClose: () => void;
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

export interface BannersPaginationProps {
  page: number;
  totalPages: number;
  onPage: (page: number) => void;
}
