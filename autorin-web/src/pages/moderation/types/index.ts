import type { Part } from "@/types";

export type { Part };

export interface ModerationToolbarProps {
  search: string;
  canClear: boolean;
  onSearchChange: (value: string) => void;
  onClear: () => void;
}

export interface ModerationTableProps {
  rows: Part[];
  loading: boolean;
  busyId: string | null;
  onApprove: (part: Part) => void;
  onReject: (part: Part) => void;
}

export interface ModerationPaginationProps {
  page: number;
  totalPages: number;
  onPage: (page: number) => void;
}

export interface ApproveDialogProps {
  open: boolean;
  partName: string;
  busy?: boolean;
  onCancel: () => void;
  onConfirm: () => void;
}

export interface RejectDialogProps {
  open: boolean;
  partName: string;
  note: string;
  busy?: boolean;
  onNoteChange: (value: string) => void;
  onCancel: () => void;
  onConfirm: () => void;
}
