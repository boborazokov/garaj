import { useEffect, useRef, useState } from "react";
import { useLanguage, type LocalizedText } from "@/lib/i18n";
import { cn } from "@/lib/utils";

interface BrandLoadingProps {
  /** Full-viewport cover (default) or inline block. */
  fullScreen?: boolean;
  className?: string;
  /** How long the boot splash runs (ms) — drives the step bar. */
  durationMs?: number;
}

const TEXTS = {
  title: {
    uz: "Garage tayyorlanmoqda",
    ru: "Готовим Garage",
    en: "Preparing your garage",
  },
  subtitle: {
    uz: "Tizimga kirdingiz — admin panel ochilmoqda…",
    ru: "Вы вошли — открываем админ-панель…",
    en: "You're signed in — opening the admin hub…",
  },
  footer: {
    uz: "Bu bir zumda tugaydi.",
    ru: "Это займёт всего мгновение.",
    en: "This only takes a moment.",
  },
} as const satisfies Record<string, LocalizedText>;

const STEPS = 3;

export function BrandLoading({
  fullScreen = true,
  className,
  durationMs = 3200,
}: BrandLoadingProps) {
  const { t } = useLanguage();
  const videoRef = useRef<HTMLVideoElement>(null);
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const el = videoRef.current;
    if (!el) return;
    el.muted = true;
    el.defaultMuted = true;
    el.volume = 0;
    void el.play().catch(() => {
    });
  }, []);

  useEffect(() => {
    const started = performance.now();
    let frame = 0;

    const tick = (now: number) => {
      const ratio = Math.min(1, (now - started) / durationMs);
      const eased = 1 - (1 - ratio) ** 1.6;
      setProgress(eased);
      if (ratio < 1) {
        frame = requestAnimationFrame(tick);
      }
    };

    frame = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frame);
  }, [durationMs]);

  const activeStep = Math.min(
    STEPS - 1,
    Math.floor(progress * STEPS + (progress >= 1 ? 0 : 0.001)),
  );

  return (
    <div
      className={
        className ??
        (fullScreen
          ? "fixed inset-0 z-[100] flex flex-col items-center bg-white px-6 pt-[22vh] sm:pt-[24vh]"
          : "relative flex flex-col items-center overflow-hidden bg-white px-4 pt-14")
      }
      role="status"
      aria-live="polite"
      aria-label={t(TEXTS.title)}
    >
      <div className="flex w-full max-w-[420px] flex-col items-center">
        <div className="mb-0 h-[240px] w-[240px] max-h-[48vw] max-w-[48vw] overflow-hidden bg-white sm:h-[280px] sm:w-[280px]">
          <video
            ref={videoRef}
            className="h-full w-full scale-[1.06] object-cover brightness-[1.04]"
            src="/brand/splash_loading.mp4?v=3"
            autoPlay
            muted
            playsInline
            loop
            preload="auto"
          />
        </div>

        <h1 className="-mt-2 m-0 text-center text-[28px] font-semibold tracking-[-0.5px] text-[#111827] sm:text-[32px]">
          {t(TEXTS.title)}
        </h1>
        <p className="mt-2 mb-0 text-center text-[15px] leading-5 text-[#6b7280]">
          {t(TEXTS.subtitle)}
        </p>

        <div className="mt-7 w-full max-w-[280px]">
          <div className="h-1.5 overflow-hidden rounded-full bg-[#e8eefc]">
            <div
              className="h-full rounded-full bg-gradient-to-r from-[#226DF7] to-[#5b93ff] transition-[width] duration-150 ease-out"
              style={{ width: `${Math.max(6, progress * 100)}%` }}
            />
          </div>

          <div className="mt-3.5 flex items-center justify-center gap-2">
            {Array.from({ length: STEPS }, (_, index) => (
              <span
                key={index}
                className={cn(
                  "size-2 rounded-full transition-colors duration-300",
                  index <= activeStep ? "bg-[#226DF7]" : "bg-[#c7d7fb]",
                )}
              />
            ))}
          </div>
        </div>

        <p
          className="mb-0 text-center text-[13px] leading-5 text-[#9ca3af]"
          style={{ marginTop: 28 }}
        >
          {t(TEXTS.footer)}
        </p>
      </div>
    </div>
  );
}
