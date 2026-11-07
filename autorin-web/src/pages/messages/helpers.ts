import type { ReactNode } from "react";
import { createElement, Fragment } from "react";
import type { LanguageCode, LocalizedText } from "@/lib/i18n";
import { MESSAGES_TEXTS, PINNED_STORAGE_KEY } from "./constants";
import type { ChatConversation, ChatMessage, ChatParticipant, TimelineItem } from "./types";

export function peerOf(
  conversation: ChatConversation,
  currentUserId: string,
): ChatParticipant | undefined {
  return (
    conversation.participants.find((p) => p._id !== currentUserId) ??
    conversation.participants[0]
  );
}

export function initialsOf(name?: string | null): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/).slice(0, 2);
  return parts.map((p) => p[0]?.toUpperCase() ?? "").join("") || "?";
}

export function formatRelative(iso?: string | null, language: LanguageCode = "ru"): string {
  if (!iso) return "";
  const date = new Date(iso);
  if (Number.isNaN(date.getTime())) return "";
  const locale = language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU";
  const now = new Date();
  const sameDay =
    date.getFullYear() === now.getFullYear() &&
    date.getMonth() === now.getMonth() &&
    date.getDate() === now.getDate();
  if (sameDay) {
    return date.toLocaleTimeString(locale, {
      hour: "2-digit",
      minute: "2-digit",
    });
  }
  const diffDays = Math.floor((now.getTime() - date.getTime()) / 86_400_000);
  if (diffDays < 7) {
    return date.toLocaleDateString(locale, { weekday: "short" });
  }
  return date.toLocaleDateString(locale, { day: "2-digit", month: "2-digit" });
}

export function formatMessageTime(iso: string, language: LanguageCode = "ru"): string {
  const locale = language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU";
  return new Date(iso).toLocaleTimeString(locale, {
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function formatSeconds(value: number): string {
  if (!Number.isFinite(value) || value <= 0) return "0:00";
  const total = Math.round(value);
  const m = Math.floor(total / 60);
  const s = total % 60;
  return `${m}:${s.toString().padStart(2, "0")}`;
}

export function renderLastMessagePreview(
  text: string,
  t: (value: LocalizedText) => string,
): string {
  if (!text) return t(MESSAGES_TEXTS.noPreview);
  if (text === "[photo]") return t(MESSAGES_TEXTS.photoPreview);
  if (text === "[voice]") return t(MESSAGES_TEXTS.voicePreview);
  return text;
}

export function readPinnedIds(): Set<string> {
  try {
    const raw = window.localStorage.getItem(PINNED_STORAGE_KEY);
    if (!raw) return new Set();
    const parsed = JSON.parse(raw) as unknown;
    if (!Array.isArray(parsed)) return new Set();
    return new Set(parsed.filter((id): id is string => typeof id === "string"));
  } catch {
    return new Set();
  }
}

export function writePinnedIds(ids: Set<string>) {
  window.localStorage.setItem(PINNED_STORAGE_KEY, JSON.stringify([...ids]));
}

function dayKey(date: Date): string {
  return `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`;
}

export function buildTimeline(
  messages: ChatMessage[],
  t: (value: LocalizedText) => string,
  language: LanguageCode,
): TimelineItem[] {
  const locale = language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU";
  const now = new Date();
  const today = dayKey(now);
  const yesterdayDate = new Date(now);
  yesterdayDate.setDate(now.getDate() - 1);
  const yesterday = dayKey(yesterdayDate);

  const items: TimelineItem[] = [];
  let lastDay = "";

  for (const message of messages) {
    const created = new Date(message.createdAt);
    const key = dayKey(created);
    if (key !== lastDay) {
      lastDay = key;
      let label: string;
      if (key === today) label = t(MESSAGES_TEXTS.today);
      else if (key === yesterday) label = t(MESSAGES_TEXTS.yesterday);
      else {
        label = created.toLocaleDateString(locale, {
          day: "numeric",
          month: "long",
          year: created.getFullYear() === now.getFullYear() ? undefined : "numeric",
        });
      }
      items.push({ kind: "day", key: `day-${key}`, label });
    }
    items.push({ kind: "message", key: message._id, message });
  }

  return items;
}

export function linkifyText(text: string): ReactNode {
  const nodes: ReactNode[] = [];
  const re = /(https?:\/\/[^\s<]+[^.,;:!?\s])/g;
  let last = 0;
  let match: RegExpExecArray | null;
  let index = 0;
  while ((match = re.exec(text)) !== null) {
    if (match.index > last) nodes.push(text.slice(last, match.index));
    nodes.push(
      createElement(
        "a",
        {
          key: `url-${index++}`,
          href: match[0],
          target: "_blank",
          rel: "noreferrer",
          className: "underline underline-offset-2",
          style: { color: "#226DF7" },
        },
        match[0],
      ),
    );
    last = match.index + match[0].length;
  }
  if (last < text.length) nodes.push(text.slice(last));
  if (nodes.length === 0) return text;
  if (nodes.length === 1) return nodes[0];
  return createElement(Fragment, null, ...nodes);
}
