import { useMemo } from "react";
import { CheckCheck, CornerUpLeft } from "lucide-react";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import { MESSAGES_COLORS, MESSAGES_TEXTS } from "../../constants";
import { formatMessageTime, linkifyText } from "../../helpers";
import type { MessageBubbleProps } from "../../types";
import { VoicePlayer } from "../VoicePlayer";

export function MessageBubble({ message, isMine }: MessageBubbleProps) {
  const { t, language } = useLanguage();
  const time = formatMessageTime(message.createdAt, language);
  const text = message.text?.trim();
  const images = message.images ?? [];
  const hasImages = images.length > 0;
  const hasVoice = !!message.voiceUrl?.trim();
  const hasReply = !!message.replyTo;
  const readByOthers = (message.readBy ?? []).length > 1;
  const senderLabel =
    message.sender.name?.trim() ||
    message.sender.phone ||
    t(MESSAGES_TEXTS.userFallback);

  return (
    <div
      className={`flex w-full ${isMine ? "justify-end" : "justify-start"}`}
    >
      <div
        className="flex max-w-[min(78%,520px)] flex-col gap-1 overflow-hidden rounded-[12px] px-3.5 py-2 text-[13px] shadow-sm"
        style={
          isMine
            ? {
                background: MESSAGES_COLORS.bubbleOutgoing,
                color: "#ffffff",
              }
            : {
                background: MESSAGES_COLORS.bubbleIncoming,
                color: MESSAGES_COLORS.text,
                boxShadow: `inset 0 0 0 1px ${MESSAGES_COLORS.border}`,
              }
        }
      >
        {!isMine && (
          <p
            className="text-[12px] font-semibold leading-tight"
            style={{ color: MESSAGES_COLORS.accent }}
          >
            {senderLabel}
          </p>
        )}

        {hasReply && (
          <ReplyQuote
            isMine={isMine}
            senderName={message.replyToSenderName}
            text={message.replyToText}
          />
        )}

        {hasImages && <ImageGallery images={images} />}

        {hasVoice && (
          <VoicePlayer
            url={mediaUrl(message.voiceUrl!)}
            durationMs={message.voiceDurationMs ?? null}
            isMine={isMine}
          />
        )}

        {text && (
          <p
            className="whitespace-pre-wrap break-words leading-snug"
            style={isMine ? { color: "#ffffff" } : undefined}
          >
            {isMine ? text : linkifyText(text)}
          </p>
        )}

        <div
          className="flex items-center justify-end gap-1 text-[10px] leading-none"
          style={{
            color: isMine ? "rgba(255,255,255,0.85)" : MESSAGES_COLORS.muted,
          }}
        >
          <span>{time}</span>
          {isMine && readByOthers && <CheckCheck className="size-3" />}
        </div>
      </div>
    </div>
  );
}

function ReplyQuote({
  isMine,
  senderName,
  text,
}: {
  isMine: boolean;
  senderName?: string | null;
  text?: string | null;
}) {
  return (
    <div
      className="flex items-stretch gap-2 rounded-lg px-2 py-1 text-[12px]"
      style={{
        background: isMine ? "rgba(255,255,255,0.16)" : MESSAGES_COLORS.accentSoft,
      }}
    >
      <span
        className="w-[3px] rounded"
        style={{ background: isMine ? "#ffffff" : MESSAGES_COLORS.accent }}
      />
      <div className="flex min-w-0 flex-col">
        {senderName && (
          <span
            className="truncate text-[11px] font-bold"
            style={{ color: isMine ? "#ffffff" : MESSAGES_COLORS.accent }}
          >
            <CornerUpLeft className="mr-1 inline size-3 align-[-1px]" />
            {senderName}
          </span>
        )}
        {text && (
          <span
            className="truncate"
            style={{
              color: isMine ? "rgba(255,255,255,0.9)" : MESSAGES_COLORS.muted,
            }}
          >
            {text}
          </span>
        )}
      </div>
    </div>
  );
}

function ImageGallery({ images }: { images: string[] }) {
  const resolved = useMemo(
    () => images.map((item) => mediaUrl(item)).filter(Boolean),
    [images],
  );
  if (resolved.length === 0) return null;
  if (resolved.length === 1) {
    return (
      <a
        href={resolved[0]}
        target="_blank"
        rel="noreferrer"
        className="block overflow-hidden rounded-[10px]"
      >
        <img
          src={resolved[0]}
          alt="attachment"
          className="max-h-[280px] w-auto rounded-[10px] object-cover"
        />
      </a>
    );
  }
  const preview = resolved.slice(0, 4);
  const overflow = resolved.length - preview.length;
  return (
    <div className="grid grid-cols-2 gap-1 overflow-hidden rounded-[10px]">
      {preview.map((src, idx) => {
        const isLast = idx === 3 && overflow > 0;
        return (
          <a
            key={src + idx}
            href={src}
            target="_blank"
            rel="noreferrer"
            className="relative aspect-square overflow-hidden"
          >
            <img
              src={src}
              alt={`attachment-${idx + 1}`}
              className="h-full w-full object-cover"
            />
            {isLast && (
              <div
                className="absolute inset-0 flex items-center justify-center bg-black/55 text-base font-bold"
                style={{ color: "#ffffff" }}
              >
                +{overflow}
              </div>
            )}
          </a>
        );
      })}
    </div>
  );
}
