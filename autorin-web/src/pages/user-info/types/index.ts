import type { Part, UserRow } from "@/types";
import type { ChatParticipant } from "@/pages/messages/types";

export type { Part, UserRow, ChatParticipant };

export type UserInfoPeer = ChatParticipant & {
  role?: string | null;
};

export interface UserInfoLocationState {
  peer?: UserInfoPeer | null;
  /** Full row from Users table — keeps role accurate on open. */
  user?: UserRow | null;
}

export interface UserProfileCardProps {
  user: UserRow;
}

export type UserInfoTab = "stats" | "wallet" | "products";

export interface UserStatsPanelProps {
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
