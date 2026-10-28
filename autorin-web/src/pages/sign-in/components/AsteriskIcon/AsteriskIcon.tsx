interface AsteriskIconProps {
  size?: number;
  color?: string;
  className?: string;
}

export function AsteriskIcon({
  size = 28,
  color = "#ffffff",
  className,
}: AsteriskIconProps) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      <path
        d="M12 2.5v19M2.5 12h19M5.28 5.28l13.44 13.44M5.28 18.72l13.44-13.44"
        stroke={color}
        strokeWidth="3.2"
        strokeLinecap="round"
      />
    </svg>
  );
}
