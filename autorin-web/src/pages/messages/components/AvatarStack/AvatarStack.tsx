import { MESSAGES_COLORS } from "../../constants";
import { initialsOf } from "../../helpers";
import type { AvatarStackProps } from "../../types";

export function AvatarStack({
  participants,
  currentUserId,
  max = 3,
}: AvatarStackProps) {
  const others = participants.filter((p) => p._id !== currentUserId);
  const visible = others.slice(0, max);
  const overflow = Math.max(0, others.length - visible.length);

  if (visible.length === 0) return null;

  return (
    <div className="flex items-center">
      {visible.map((person, index) => (
        <div
          key={person._id}
          className="flex size-8 items-center justify-center rounded-full border-2 border-white text-[11px] font-semibold"
          style={{
            marginLeft: index === 0 ? 0 : -8,
            zIndex: visible.length - index,
            background: MESSAGES_COLORS.accentSoft,
            color: MESSAGES_COLORS.accent,
            borderColor: "#ffffff",
            boxShadow: `0 0 0 1px ${MESSAGES_COLORS.border}`,
          }}
          title={person.name?.trim() || person.phone || undefined}
        >
          {initialsOf(person.name || person.phone)}
        </div>
      ))}
      {overflow > 0 && (
        <div
          className="flex size-8 items-center justify-center rounded-full border-2 border-white text-[11px] font-semibold"
          style={{
            marginLeft: -8,
            background: MESSAGES_COLORS.searchBg,
            color: MESSAGES_COLORS.textSecondary,
            boxShadow: `0 0 0 1px ${MESSAGES_COLORS.border}`,
          }}
        >
          +{overflow}
        </div>
      )}
    </div>
  );
}
