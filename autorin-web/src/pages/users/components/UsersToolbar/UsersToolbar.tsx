import { Search, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useLanguage } from "@/lib/i18n";
import {
  ROLE_LABELS,
  ROLE_OPTIONS,
  USERS_TEXTS,
} from "../../constants";
import type { RoleFilter, UsersToolbarProps, VerifiedFilter } from "../../types";
import { FilterSelect } from "../FilterSelect";

export function UsersToolbar({
  search,
  role,
  verified,
  canClear,
  onSearchChange,
  onRoleChange,
  onVerifiedChange,
  onClear,
}: UsersToolbarProps) {
  const { t } = useLanguage();

  return (
    <div className="flex items-center gap-2 px-3 py-3">
      <div className="relative w-full max-w-[340px] shrink-0">
        <Search className="pointer-events-none absolute top-1/2 left-2.5 size-[15px] -translate-y-1/2 text-muted-foreground" />
        <Input
          value={search}
          onChange={(event) => onSearchChange(event.target.value)}
          placeholder={t(USERS_TEXTS.searchPlaceholder)}
          aria-label={t(USERS_TEXTS.searchPlaceholder)}
          className="h-9 pl-[34px]"
        />
      </div>

      <div className="ml-auto flex shrink-0 items-center gap-2">
        <FilterSelect
          value={role}
          ariaLabel={t(USERS_TEXTS.role)}
          className="w-[130px] flex-none"
          onChange={(value) => onRoleChange((value || "") as RoleFilter)}
          options={[
            { value: "", label: t(USERS_TEXTS.allRoles) },
            ...ROLE_OPTIONS.map((id) => ({
              value: id,
              label: t(ROLE_LABELS[id]),
            })),
          ]}
        />

        <FilterSelect
          value={verified}
          ariaLabel={t(USERS_TEXTS.verification)}
          className="w-[150px] flex-none"
          onChange={(value) =>
            onVerifiedChange((value || "") as VerifiedFilter)
          }
          options={[
            { value: "", label: t(USERS_TEXTS.allVerification) },
            { value: "verified", label: t(USERS_TEXTS.verifiedOnly) },
            { value: "unverified", label: t(USERS_TEXTS.unverifiedOnly) },
          ]}
        />

        {canClear ? (
          <Button
            type="button"
            variant="outline"
            size="sm"
            className="h-9 shrink-0 gap-1.5 px-2.5"
            onClick={onClear}
          >
            <X className="size-3.5" />
            {t(USERS_TEXTS.clearFilters)}
          </Button>
        ) : null}
      </div>
    </div>
  );
}
