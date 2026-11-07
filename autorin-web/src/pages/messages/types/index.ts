import type { ChatConversation, ChatMessage, ChatParticipant } from "@/types";

export type { ChatConversation, ChatMessage, ChatParticipant };

export interface ConversationSidebarProps {
  conversations: ChatConversation[];
  currentUserId: string;
  selectedId: string | null;
  pinnedIds: Set<string>;
  loading: boolean;
  search: string;
  onSearchChange(value: string): void;
  onSelect(id: string): void;
  onTogglePin(id: string): void;
  onRefresh(): void;
}

export interface ConversationItemProps {
  conversation: ChatConversation;
  peer?: ChatParticipant;
  active: boolean;
  pinned: boolean;
  onSelect(): void;
  onTogglePin(): void;
}

export interface ConversationThreadProps {
  conversation: ChatConversation;
  currentUserId: string;
  mockMode?: boolean;
  onBack(): void;
  onAfterSend(): void;
}

export interface MessageBubbleProps {
  message: ChatMessage;
  isMine: boolean;
}

export interface AvatarStackProps {
  participants: ChatParticipant[];
  currentUserId: string;
  max?: number;
}

export type TimelineItem =
  | { kind: "day"; key: string; label: string }
  | { kind: "message"; key: string; message: ChatMessage };
