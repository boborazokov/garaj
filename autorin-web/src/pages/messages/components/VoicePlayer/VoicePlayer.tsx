import { useEffect, useRef, useState } from "react";
import { Mic, Pause, Play } from "lucide-react";
import { MESSAGES_COLORS } from "../../constants";
import { formatSeconds } from "../../helpers";

interface VoicePlayerProps {
  url: string;
  durationMs: number | null;
  isMine: boolean;
}

export function VoicePlayer({ url, durationMs, isMine }: VoicePlayerProps) {
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const [playing, setPlaying] = useState(false);
  const [position, setPosition] = useState(0);
  const [total, setTotal] = useState(
    durationMs && durationMs > 0 ? durationMs / 1000 : 0,
  );

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;
    const onTime = () => setPosition(audio.currentTime);
    const onMeta = () => {
      if (Number.isFinite(audio.duration) && audio.duration > 0) {
        setTotal(audio.duration);
      }
    };
    const onEnd = () => {
      setPlaying(false);
      setPosition(0);
    };
    const onPlay = () => setPlaying(true);
    const onPause = () => setPlaying(false);
    audio.addEventListener("timeupdate", onTime);
    audio.addEventListener("loadedmetadata", onMeta);
    audio.addEventListener("ended", onEnd);
    audio.addEventListener("play", onPlay);
    audio.addEventListener("pause", onPause);
    return () => {
      audio.removeEventListener("timeupdate", onTime);
      audio.removeEventListener("loadedmetadata", onMeta);
      audio.removeEventListener("ended", onEnd);
      audio.removeEventListener("play", onPlay);
      audio.removeEventListener("pause", onPause);
    };
  }, []);

  function toggle() {
    const audio = audioRef.current;
    if (!audio) return;
    if (audio.paused) {
      void audio.play().catch(() => {});
    } else {
      audio.pause();
    }
  }

  const progress = total > 0 ? Math.min(1, position / total) : 0;
  const display = position > 0 ? position : total;
  const accent = isMine ? "#ffffff" : MESSAGES_COLORS.accent;
  const track = isMine ? "rgba(255,255,255,0.28)" : "rgba(34,109,247,0.2)";
  const fill = isMine ? "#ffffff" : MESSAGES_COLORS.accent;

  return (
    <div className="flex w-[220px] items-center gap-2">
      <button
        type="button"
        onClick={toggle}
        className="flex size-8 shrink-0 items-center justify-center rounded-full transition"
        style={{
          background: isMine ? "rgba(255,255,255,0.18)" : MESSAGES_COLORS.accentSoft,
        }}
      >
        {playing ? (
          <Pause className="size-4" style={{ color: accent }} />
        ) : (
          <Play className="size-4" style={{ color: accent }} />
        )}
      </button>
      <div className="flex-1">
        <div className="h-[3px] w-full rounded" style={{ background: track }}>
          <div
            className="h-full rounded"
            style={{ width: `${progress * 100}%`, background: fill }}
          />
        </div>
        <div
          className="mt-1 flex items-center gap-1 text-[10px]"
          style={{ color: isMine ? "rgba(255,255,255,0.85)" : MESSAGES_COLORS.muted }}
        >
          <Mic className="size-3" />
          <span>{formatSeconds(display)}</span>
        </div>
      </div>
      <audio ref={audioRef} src={url} preload="metadata" />
    </div>
  );
}
