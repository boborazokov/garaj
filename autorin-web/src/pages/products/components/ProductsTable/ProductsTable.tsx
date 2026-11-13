import { BarChart3, Package, Pin, PinOff, Trash2 } from "lucide-react";
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
import { categoryLabel } from "@/lib/category-names";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import { cn } from "@/lib/utils";
import type { CategoryRow, ItemStatus, Part } from "@/types";
import { PRODUCTS_TEXTS, PROMOTE_PLAN_LABELS, STATUS_LABELS } from "../../constants";
import { formatCount, formatPrice, isPartRecommended, skuFromId } from "../../helpers";
import type { ProductsTableProps } from "../../types";

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

function ProductThumb({ src, alt }: { src?: string; alt: string }) {
  const url = mediaUrl(src);
  if (!url) {
    return (
      <div className="flex size-[42px] shrink-0 items-center justify-center rounded-[8px] bg-slate-100 text-muted-foreground">
        <Package className="size-4" />
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

export function ProductsTable({
  rows,
  loading,
  selectedIds,
  onToggleAll,
  onToggleRow,
  onRecommend,
  onDelete,
  onOpenStats,
}: ProductsTableProps) {
  const { t } = useLanguage();
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
                aria-label={t(PRODUCTS_TEXTS.selectAll)}
                onChange={(event) => onToggleAll(event.target.checked)}
              />
            </TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.productName)}</TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.postedBy)}</TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.unitPrice)}</TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.quantity)}</TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.views)}</TableHead>
            <TableHead>{t(PRODUCTS_TEXTS.status)}</TableHead>
            <TableHead className="text-right">{t(PRODUCTS_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <ProductsSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((part) => (
                <ProductRow
                  key={part._id}
                  part={part}
                  selected={selectedIds.includes(part._id)}
                  onToggleRow={onToggleRow}
                  onRecommend={onRecommend}
                  onDelete={onDelete}
                  onOpenStats={onOpenStats}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(PRODUCTS_TEXTS.empty)}
        </p>
      ) : null}
    </div>
  );
}

function ProductsSkeletonRow() {
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
            <Skeleton className="h-3 w-24" />
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
        <Skeleton className="h-3.5 w-16" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-10" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-10" />
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

function ProductRow({
  part,
  selected,
  onToggleRow,
  onRecommend,
  onDelete,
  onOpenStats,
}: {
  part: Part;
  selected: boolean;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (part: Part) => void;
  onDelete: (part: Part) => void;
  onOpenStats: (part: Part) => void;
}) {
  const { t, language } = useLanguage();
  const recommended = isPartRecommended(part);
  const planLabel = part.promotionPlan
    ? t(PROMOTE_PLAN_LABELS[part.promotionPlan] ?? PROMOTE_PLAN_LABELS.TOP)
    : null;
  const categoryName = part.category
    ? categoryLabel(part.category as Pick<CategoryRow, "name" | "names">, language)
    : "";

  return (
    <TableRow data-state={selected ? "selected" : undefined}>
      <TableCell>
        <input
          type="checkbox"
          className="size-4"
          checked={selected}
          aria-label={t(PRODUCTS_TEXTS.selectRow)}
          onChange={(event) => onToggleRow(part._id, event.target.checked)}
        />
      </TableCell>
      <TableCell>
        <div className="flex min-w-[220px] items-center gap-2.5">
          <ProductThumb src={part.images?.[0]} alt={part.name} />
          <div className="min-w-0">
            <div className="flex items-center gap-1.5 font-semibold leading-tight text-foreground">
              <span className="truncate" title={part.name}>
                {part.name}
              </span>
              {recommended ? (
                <Badge
                  variant="secondary"
                  className="h-5 shrink-0 bg-primary/8 px-1.5 text-[10px] font-semibold text-primary"
                >
                  {planLabel ?? t(PRODUCTS_TEXTS.promoted)}
                </Badge>
              ) : null}
            </div>
            <div className="mt-0.5 text-[11px] text-muted-foreground">
              {t(PRODUCTS_TEXTS.sku)} {skuFromId(part._id)}
              {categoryName ? ` · ${categoryName}` : ""}
            </div>
          </div>
        </div>
      </TableCell>
      <TableCell>
        {part.seller ? (
          <div className="leading-tight">
            <div className="font-medium text-foreground">{part.seller.name?.trim() || "—"}</div>
            {part.seller.phone ? (
              <div className="mt-0.5 text-[11px] text-muted-foreground">{part.seller.phone}</div>
            ) : null}
          </div>
        ) : (
          <span className="text-muted-foreground">—</span>
        )}
      </TableCell>
      <TableCell>{formatPrice(part.price, part.currency, language)}</TableCell>
      <TableCell>{formatCount(part.quantity ?? 0, language)}</TableCell>
      <TableCell>{formatCount(part.viewsCount ?? 0, language)}</TableCell>
      <TableCell>
        <Badge variant={STATUS_BADGE[part.status]}>{t(STATUS_LABELS[part.status])}</Badge>
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            title={t(PRODUCTS_TEXTS.stats)}
            aria-label={t(PRODUCTS_TEXTS.stats)}
            onClick={() => onOpenStats(part)}
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
            title={recommended ? t(PRODUCTS_TEXTS.unpin) : t(PRODUCTS_TEXTS.pin)}
            aria-label={recommended ? t(PRODUCTS_TEXTS.unpin) : t(PRODUCTS_TEXTS.pin)}
            onClick={() => onRecommend(part)}
          >
            {recommended ? <PinOff className="size-3.5" /> : <Pin className="size-3.5" />}
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-red-200 bg-red-50 text-destructive hover:bg-red-100 hover:text-destructive"
            title={t(PRODUCTS_TEXTS.delete)}
            aria-label={t(PRODUCTS_TEXTS.delete)}
            onClick={() => onDelete(part)}
          >
            <Trash2 className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
