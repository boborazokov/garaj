import { useState } from "react";
import { BarChart3, Pin, PinOff, Trash2, Wrench } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import { cn } from "@/lib/utils";
import type { ItemStatus, WorkshopRow } from "@/types";
import {
  PROMOTION_PLAN_LABELS,
  STATUS_LABELS,
  WORKSHOPS_TEXTS,
} from "../../constants";
import {
  formatPromoUntil,
  idTail,
  isWorkshopRecommended,
  workshopCategoryLabel,
  workshopPlace,
} from "../../helpers";
import type { WorkshopsTableProps } from "../../types";
import { StatsDialog } from "../StatsDialog";

const SKELETON_ROWS = 6;

const STATUS_BADGE: Record<
  ItemStatus,
  "success" | "warning" | "muted" | "destructive"
> = {
  ACTIVE: "success",
  PENDING_MODERATION: "warning",
  ARCHIVED: "muted",
  REJECTED: "destructive",
};

function WorkshopThumb({ src, alt }: { src?: string; alt: string }) {
  const url = mediaUrl(src);
  if (!url) {
    return (
      <div className="flex size-[42px] shrink-0 items-center justify-center rounded-[8px] bg-slate-100 text-muted-foreground">
        <Wrench className="size-4" />
      </div>
    );
  }
  return (
    <img
      src={url}
      alt={alt}
      className="size-[42px] shrink-0 rounded-[8px] bg-slate-100 object-cover"
    />
  );
}

export function WorkshopsTable({
  rows,
  loading,
  selectedIds,
  onToggleAll,
  onToggleRow,
  onRecommend,
  onDelete,
}: WorkshopsTableProps) {
  const { t } = useLanguage();
  const [statsWorkshop, setStatsWorkshop] = useState<WorkshopRow | null>(null);
  const allChecked = rows.length > 0 && rows.every((row) => selectedIds.includes(row._id));
  const showSkeleton = loading && rows.length === 0;

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead className="w-9">
              <input
                type="checkbox"
                className="size-4"
                checked={allChecked}
                aria-label={t(WORKSHOPS_TEXTS.selectAll)}
                onChange={(event) => onToggleAll(event.target.checked)}
              />
            </TableHead>
            <TableHead>{t(WORKSHOPS_TEXTS.workshopName)}</TableHead>
            <TableHead>{t(WORKSHOPS_TEXTS.postedBy)}</TableHead>
            <TableHead>{t(WORKSHOPS_TEXTS.location)}</TableHead>
            <TableHead>{t(WORKSHOPS_TEXTS.topPlan)}</TableHead>
            <TableHead>{t(WORKSHOPS_TEXTS.status)}</TableHead>
            <TableHead className="text-right">{t(WORKSHOPS_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <WorkshopsSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((workshop) => (
                <WorkshopRowView
                  key={workshop._id}
                  workshop={workshop}
                  selected={selectedIds.includes(workshop._id)}
                  onToggleRow={onToggleRow}
                  onRecommend={onRecommend}
                  onDelete={onDelete}
                  onOpenStats={setStatsWorkshop}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(WORKSHOPS_TEXTS.empty)}
        </p>
      ) : null}

      <StatsDialog
        workshop={statsWorkshop}
        open={Boolean(statsWorkshop)}
        onClose={() => setStatsWorkshop(null)}
      />
    </div>
  );
}

function WorkshopsSkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
      <TableCell>
        <Skeleton className="size-4 rounded-[4px]" />
      </TableCell>
      <TableCell>
        <div className="flex min-w-[220px] items-center gap-2.5">
          <Skeleton className="size-[42px] shrink-0 rounded-[8px]" />
          <div className="flex min-w-0 flex-1 flex-col gap-1.5">
            <Skeleton className="h-3.5 w-40" />
            <Skeleton className="h-3 w-28" />
          </div>
        </div>
      </TableCell>
      <TableCell>
        <div className="flex flex-col gap-1.5">
          <Skeleton className="h-3.5 w-24" />
          <Skeleton className="h-3 w-20" />
        </div>
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-32" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-8 w-16 rounded-[8px]" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-5 w-16 rounded-full" />
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Skeleton className="size-8 rounded-[8px]" />
          <Skeleton className="size-8 rounded-[8px]" />
          <Skeleton className="size-8 rounded-[8px]" />
        </div>
      </TableCell>
    </TableRow>
  );
}

function WorkshopRowView({
  workshop,
  selected,
  onToggleRow,
  onRecommend,
  onDelete,
  onOpenStats,
}: {
  workshop: WorkshopRow;
  selected: boolean;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (workshop: WorkshopRow) => void;
  onDelete: (workshop: WorkshopRow) => void;
  onOpenStats: (workshop: WorkshopRow) => void;
}) {
  const { t, language } = useLanguage();
  const recommended = isWorkshopRecommended(workshop);
  const serviceNames = (workshop.categories ?? [])
    .map((item) => workshopCategoryLabel(item, language))
    .filter(Boolean)
    .slice(0, 2);
  const place = workshopPlace(workshop);
  const thumb = workshop.coverImage || workshop.logo || workshop.gallery?.[0];
  const planLabel = workshop.promotionPlan
    ? t(PROMOTION_PLAN_LABELS[workshop.promotionPlan] ?? PROMOTION_PLAN_LABELS.TOP)
    : null;
  const until = formatPromoUntil(workshop.promotedUntil, language);

  return (
    <TableRow data-state={selected ? "selected" : undefined}>
      <TableCell>
        <input
          type="checkbox"
          className="size-4"
          checked={selected}
          aria-label={t(WORKSHOPS_TEXTS.selectRow)}
          onChange={(event) => onToggleRow(workshop._id, event.target.checked)}
        />
      </TableCell>
      <TableCell>
        <div className="flex min-w-[220px] items-center gap-2.5">
          <WorkshopThumb src={thumb} alt={workshop.name} />
          <div className="min-w-0">
            <div className="flex items-center gap-1.5 font-semibold leading-tight text-foreground">
              <span className="truncate" title={workshop.name}>
                {workshop.name}
              </span>
              {recommended ? (
                <Badge
                  variant="secondary"
                  className="h-5 shrink-0 bg-primary/8 px-1.5 text-[10px] font-semibold text-primary"
                >
                  {t(WORKSHOPS_TEXTS.promoted)}
                </Badge>
              ) : null}
              {workshop.verified ? (
                <Badge
                  variant="secondary"
                  className="h-5 shrink-0 bg-emerald-50 px-1.5 text-[10px] font-semibold text-emerald-700"
                >
                  {t(WORKSHOPS_TEXTS.verified)}
                </Badge>
              ) : null}
            </div>
            <div className="mt-0.5 text-[11px] text-muted-foreground">
              {t(WORKSHOPS_TEXTS.idLabel)} {idTail(workshop._id)}
              {serviceNames.length
                ? ` · ${serviceNames.join(", ")}`
                : ` · ${t(WORKSHOPS_TEXTS.services)} —`}
            </div>
          </div>
        </div>
      </TableCell>
      <TableCell>
        {workshop.owner ? (
          <div className="leading-tight">
            <div className="font-medium text-foreground">
              {workshop.owner.name?.trim() || "—"}
            </div>
            {workshop.owner.phone ? (
              <div className="mt-0.5 text-[11px] text-muted-foreground">
                {workshop.owner.phone}
              </div>
            ) : null}
          </div>
        ) : (
          <span className="text-muted-foreground">—</span>
        )}
      </TableCell>
      <TableCell>
        <span className="line-clamp-2 max-w-[180px] text-[13px]" title={place || undefined}>
          {place || "—"}
        </span>
      </TableCell>
      <TableCell>
        {recommended && planLabel ? (
          <div className="leading-tight">
            <div className="font-semibold text-foreground">{planLabel}</div>
            {until ? (
              <div className="mt-0.5 text-[11px] text-muted-foreground">
                {t(WORKSHOPS_TEXTS.topUntil)} {until}
              </div>
            ) : null}
          </div>
        ) : (
          <span className="text-[13px] text-muted-foreground">{t(WORKSHOPS_TEXTS.noTop)}</span>
        )}
      </TableCell>
      <TableCell>
        <Badge variant={STATUS_BADGE[workshop.status]}>
          {t(STATUS_LABELS[workshop.status])}
        </Badge>
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            title={t(WORKSHOPS_TEXTS.stats)}
            aria-label={t(WORKSHOPS_TEXTS.stats)}
            onClick={() => onOpenStats(workshop)}
          >
            <BarChart3 className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className={cn(
              "size-8",
              recommended && "border-primary bg-primary/8 text-primary",
            )}
            title={recommended ? t(WORKSHOPS_TEXTS.unpin) : t(WORKSHOPS_TEXTS.pin)}
            aria-label={recommended ? t(WORKSHOPS_TEXTS.unpin) : t(WORKSHOPS_TEXTS.pin)}
            onClick={() => onRecommend(workshop)}
          >
            {recommended ? <PinOff className="size-3.5" /> : <Pin className="size-3.5" />}
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-red-200 bg-red-50 text-destructive hover:bg-red-100 hover:text-destructive"
            title={t(WORKSHOPS_TEXTS.delete)}
            aria-label={t(WORKSHOPS_TEXTS.delete)}
            onClick={() => onDelete(workshop)}
          >
            <Trash2 className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
