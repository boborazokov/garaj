import type { Part, UserRow } from "@/types";
import type { ChatParticipant } from "@/pages/messages/types";

export type { Part, UserRow, ChatParticipant };

export interface UserInfoLocationState {
  peer?: ChatParticipant | null;
}

export interface UserProfileCardProps {
  user: UserRow;
  productsCount: number;
  activeCount: number;
  viewsCount: number;
  region?: string | null;
}

export interface UserProductsTableProps {
  rows: Part[];
  loading: boolean;
  page?: number;
  totalPages?: number;
  onPage?: (page: number) => void;
}

export interface UserInfoPaginationProps {
  page: number;
  totalPages: number;
  onPage: (page: number) => void;
}
