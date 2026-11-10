import { BarChart3, ImageIcon, Pencil, Trash2 } from "lucide-react";
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
import type { AdvertisementRow, AdvertisementStatus } from "@/types";
import { BANNERS_TEXTS, PLAN_LABELS, STATUS_LABELS } from "../../constants";
import { formatBannerDate, formatCount, formatCtr, formatUzs } from "../../helpers";
import type { BannersTableProps } from "../../types";

const SKELETON_ROWS = 6;

const STATUS_CLASS: Record<AdvertisementStatus, string> = {
  ACTIVE: "bg-emerald-50 text-emerald-700",
  PAUSED: "bg-amber-50 text-amber-700",
  QUEUED: "bg-sky-50 text-sky-700",
  EXPIRED: "bg-slate-100 text-slate-600",
};

function BannerThumb({ src, alt }: { src?: string; alt: string }) {
  const url = mediaUrl(src);
  if (!url) {
    return (
      <div className="flex h-11 w-[72px] shrink-0 items-center justify-center rounded-[8px] bg-slate-100 text-muted-foreground">
        <ImageIcon className="size-4" />
      </div>
    );
  }
  return (
    <img
      src={url}
      alt={alt}
      className="h-11 w-[72px] shrink-0 rounded-[8px] bg-slate-100 object-cover"
    />
  );
}

export function BannersTable({
  rows,
  loading,
  onEdit,
  onDelete,
  onStats,
}: BannersTableProps) {
  const { t } = useLanguage();
  const showSkeleton = loading && rows.length === 0;

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead>{t(BANNERS_TEXTS.banner)}</TableHead>
            <TableHead>{t(BANNERS_TEXTS.link)}</TableHead>
            <TableHead>{t(BANNERS_TEXTS.tariffCol)}</TableHead>
            <TableHead>{t(BANNERS_TEXTS.period)}</TableHead>
            <TableHead>{t(BANNERS_TEXTS.status)}</TableHead>
            <TableHead>{t(BANNERS_TEXTS.stats)}</TableHead>
            <TableHead className="text-right">{t(BANNERS_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <BannersSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((row) => (
                <BannerRowItem
                  key={row._id}
                  row={row}
                  onEdit={onEdit}
                  onDelete={onDelete}
                  onStats={onStats}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(BANNERS_TEXTS.empty)}
        </p>
      ) : null}
    </div>
  );
}

function BannersSkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
      <TableCell>
        <div className="flex items-center gap-2.5">
          <Skeleton className="h-11 w-[72px] rounded-[8px]" />
          <Skeleton className="h-3.5 w-28" />
        </div>
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-36" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-20" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-24" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-5 w-16 rounded-full" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-20" />
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

function BannerRowItem({
  row,
  onEdit,
  onDelete,
  onStats,
}: {
  row: AdvertisementRow;
  onEdit: (row: AdvertisementRow) => void;
  onDelete: (row: AdvertisementRow) => void;
  onStats: (row: AdvertisementRow) => void;
}) {
  const { t, language } = useLanguage();
  const start = formatBannerDate(row.startsAt, language);
  const end = formatBannerDate(row.endsAt, language);

  return (
    <TableRow>
      <TableCell>
        <div className="flex min-w-[200px] items-center gap-2.5">
          <BannerThumb src={row.bannerImageUrl} alt={row.title} />
          <div className="min-w-0">
            <div className="font-semibold leading-tight text-foreground">
              <span className="truncate" title={row.title}>
                {row.title}
              </span>
            </div>
          </div>
        </div>
      </TableCell>
      <TableCell>
        <span className="line-clamp-2 max-w-[180px] text-[13px] text-muted-foreground" title={row.link}>
          {row.link}
        </span>
      </TableCell>
      <TableCell>
        <div className="leading-tight text-[13px]">
          {row.isFree ? (
            <span className="text-muted-foreground">{t(BANNERS_TEXTS.tariffFree)}</span>
          ) : row.plan ? (
            <>
              <div className="font-medium text-foreground">
                {t(PLAN_LABELS[row.plan])}
              </div>
              {typeof row.amountPaid === "number" && row.amountPaid > 0 ? (
                <div className="mt-0.5 text-[12px] text-muted-foreground">
                  {formatUzs(row.amountPaid)}
                </div>
              ) : null}
            </>
          ) : (
            <span className="text-muted-foreground">—</span>
          )}
        </div>
      </TableCell>
      <TableCell>
        {end ? (
          <div className="leading-tight text-[13px]">
            {start ? (
              <div className="text-foreground">
                {start} → {end}
              </div>
            ) : (
              <div className="text-muted-foreground">
                {t(BANNERS_TEXTS.until)} {end}
              </div>
            )}
          </div>
        ) : (
          <span className="text-[13px] text-muted-foreground">{t(BANNERS_TEXTS.noEnd)}</span>
        )}
      </TableCell>
      <TableCell>
        <Badge
          variant="secondary"
          className={`h-5 px-1.5 text-[10px] font-semibold ${STATUS_CLASS[row.status]}`}
        >
          {t(STATUS_LABELS[row.status])}
        </Badge>
      </TableCell>
      <TableCell>
        <div className="leading-tight text-[12px] text-muted-foreground">
          <div>
            {formatCount(row.impressionCount ?? 0, language)} /{" "}
            {formatCount(row.clickCount ?? 0, language)}
          </div>
          <div className="mt-0.5 tabular-nums">{formatCtr(row.ctr ?? 0, language)}</div>
        </div>
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            aria-label={t(BANNERS_TEXTS.stats)}
            onClick={() => onStats(row)}
          >
            <BarChart3 className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            aria-label={t(BANNERS_TEXTS.edit)}
            onClick={() => onEdit(row)}
          >
            <Pencil className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 text-destructive hover:text-destructive"
            aria-label={t(BANNERS_TEXTS.delete)}
            onClick={() => onDelete(row)}
          >
            <Trash2 className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
