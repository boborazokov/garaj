import { cn } from "@/lib/utils";
import logoFull from "@/assets/brand/garage-logo-full.jpg";
import logoMark from "@/assets/brand/garage-logo-mark.jpg";

type BrandLogoVariant = "mark" | "full";

interface BrandLogoProps {
  variant?: BrandLogoVariant;
  size?: number;
  className?: string;
  alt?: string;
}

const SRC: Record<BrandLogoVariant, string> = {
  mark: logoMark,
  full: logoFull,
};

export function BrandLogo({
  variant = "mark",
  size = 36,
  className,
  alt = "Garage",
}: BrandLogoProps) {
  const isFull = variant === "full";

  return (
    <img
      src={SRC[variant]}
      alt={alt}
      height={size}
      width={isFull ? undefined : size}
      className={cn(
        "block shrink-0 object-contain",
        isFull ? "w-auto" : "rounded-[10px]",
        className,
      )}
      style={{ height: size, width: isFull ? "auto" : size }}
      draggable={false}
    />
  );
}
