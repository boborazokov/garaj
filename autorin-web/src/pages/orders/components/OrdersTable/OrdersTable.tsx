import { CircleX, ClipboardList, MessageSquare, Pin, PinOff, RotateCcw, Trash2 } from "lucide-react";
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
import type { OrderRow, OrderStatus } from "@/types";
import { ORDERS_TEXTS, STATUS_LABELS } from "../../constants";
import { formatBudget, formatDate, isOrderRecommended } from "../../helpers";
import type { OrdersTableProps } from "../../types";

const SKELETON_ROWS = 6;

const STATUS_BADGE: Record<OrderStatus, "success" | "muted" | "destructive"> = {
  ACTIVE: "success",
  CLOSED: "muted",
  CANCELLED: "destructive",
};

function OrderThumb({ src, alt }: { src?: string; alt: string }) {
  const url = mediaUrl(src);
  if (!url) {
    return (
      <div className="flex size-[42px] shrink-0 items-center justify-center rounded-[8px] bg-slate-100 text-muted-foreground">
        <ClipboardList className="size-4" />
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

export function OrdersTable({
  rows,
  loading,
  selectedIds,
  onToggleAll,
  onToggleRow,
  onRecommend,
  onOffers,
  onClose,
  onReopen,
  onDelete,
}: OrdersTableProps) {
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
                aria-label={t(ORDERS_TEXTS.selectAll)}
                onChange={(event) => onToggleAll(event.target.checked)}
              />
            </TableHead>
            <TableHead>{t(ORDERS_TEXTS.orderTitle)}</TableHead>
            <TableHead>{t(ORDERS_TEXTS.author)}</TableHead>
            <TableHead>{t(ORDERS_TEXTS.vehicle)}</TableHead>
            <TableHead>{t(ORDERS_TEXTS.budget)}</TableHead>
            <TableHead>{t(ORDERS_TEXTS.status)}</TableHead>
            <TableHead>{t(ORDERS_TEXTS.createdAt)}</TableHead>
            <TableHead className="text-right">{t(ORDERS_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <OrdersSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((order) => (
                <OrderRowView
                  key={order._id}
                  order={order}
                  selected={selectedIds.includes(order._id)}
                  onToggleRow={onToggleRow}
                  onRecommend={onRecommend}
                  onOffers={onOffers}
                  onClose={onClose}
                  onReopen={onReopen}
                  onDelete={onDelete}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(ORDERS_TEXTS.empty)}
        </p>
      ) : null}
    </div>
  );
}

function OrdersSkeletonRow() {
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
        <Skeleton className="h-3.5 w-28" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-16" />
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

function OrderRowView({
  order,
  selected,
  onToggleRow,
  onRecommend,
  onOffers,
  onClose,
  onReopen,
  onDelete,
}: {
  order: OrderRow;
  selected: boolean;
  onToggleRow: (id: string, checked: boolean) => void;
  onRecommend: (order: OrderRow) => void;
  onOffers: (order: OrderRow) => void;
  onClose: (order: OrderRow) => void;
  onReopen: (order: OrderRow) => void;
  onDelete: (order: OrderRow) => void;
}) {
  const { t, language } = useLanguage();
  const recommended = isOrderRecommended(order);
  const brandName = order.brand ? categoryLabel(order.brand, language) : "";
  const modelName = order.carModel ? categoryLabel(order.carModel, language) : "";
  const categoryName = order.partCategory
    ? categoryLabel(order.partCategory, language)
    : "";
  const yearLabel =
    order.year != null && Number.isFinite(order.year) ? String(order.year) : "";
  const vehicle =
    [brandName, modelName, yearLabel].filter(Boolean).join(" · ") || "—";
  const region = order.region?.trim() || order.location?.trim() || "";

  return (
    <TableRow data-state={selected ? "selected" : undefined}>
      <TableCell>
        <input
          type="checkbox"
          className="size-4"
          checked={selected}
          aria-label={t(ORDERS_TEXTS.selectRow)}
          onChange={(event) => onToggleRow(order._id, event.target.checked)}
        />
      </TableCell>
      <TableCell>
        <div className="flex min-w-[220px] items-center gap-2.5">
          <OrderThumb src={order.images?.[0]} alt={order.title} />
          <div className="min-w-0">
            <div className="flex items-center gap-1.5 font-semibold leading-tight text-foreground">
              <span className="truncate" title={order.title}>
                {order.title}
              </span>
              {recommended ? (
                <Badge
                  variant="secondary"
                  className="h-5 shrink-0 bg-primary/8 px-1.5 text-[10px] font-semibold text-primary"
                >
                  {t(ORDERS_TEXTS.promoted)}
                </Badge>
              ) : null}
            </div>
            <div className="mt-0.5 truncate text-[11px] text-muted-foreground">
              {order.phone}
              {categoryName ? ` · ${categoryName}` : ""}
              {region ? ` · ${region}` : ""}
            </div>
          </div>
        </div>
      </TableCell>
      <TableCell>
        {order.author ? (
          <div className="leading-tight">
            <div className="font-medium text-foreground">
              {order.author.name?.trim() || "—"}
            </div>
            {order.author.phone ? (
              <div className="mt-0.5 text-[11px] text-muted-foreground">
                {order.author.phone}
              </div>
            ) : null}
          </div>
        ) : (
          <span className="text-muted-foreground">—</span>
        )}
      </TableCell>
      <TableCell>
        <span className="text-[13px] text-foreground">{vehicle}</span>
      </TableCell>
      <TableCell>
        {formatBudget(order.budget, order.currency, language, t(ORDERS_TEXTS.negotiable))}
      </TableCell>
      <TableCell>
        <Badge variant={STATUS_BADGE[order.status]}>{t(STATUS_LABELS[order.status])}</Badge>
      </TableCell>
      <TableCell className="text-[13px] text-muted-foreground">
        {formatDate(order.createdAt, language)}
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            title={t(ORDERS_TEXTS.offers)}
            aria-label={t(ORDERS_TEXTS.offers)}
            onClick={() => onOffers(order)}
          >
            <MessageSquare className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className={cn("size-8", recommended && "border-primary bg-primary/8 text-primary")}
            title={recommended ? t(ORDERS_TEXTS.unpin) : t(ORDERS_TEXTS.pin)}
            aria-label={recommended ? t(ORDERS_TEXTS.unpin) : t(ORDERS_TEXTS.pin)}
            onClick={() => onRecommend(order)}
          >
            {recommended ? <PinOff className="size-3.5" /> : <Pin className="size-3.5" />}
          </Button>
          {order.status === "ACTIVE" ? (
            <Button
              type="button"
              variant="outline"
              size="icon"
              className="size-8 border-slate-200 text-slate-600 hover:bg-slate-100 hover:text-slate-800"
              title={t(ORDERS_TEXTS.closeOrder)}
              aria-label={t(ORDERS_TEXTS.closeOrder)}
              onClick={() => onClose(order)}
            >
              <CircleX className="size-3.5" />
            </Button>
          ) : null}
          {order.status === "CLOSED" ? (
            <Button
              type="button"
              variant="outline"
              size="icon"
              className="size-8 border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 hover:text-emerald-800"
              title={t(ORDERS_TEXTS.reopenOrder)}
              aria-label={t(ORDERS_TEXTS.reopenOrder)}
              onClick={() => onReopen(order)}
            >
              <RotateCcw className="size-3.5" />
            </Button>
          ) : null}
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-red-200 bg-red-50 text-destructive hover:bg-red-100 hover:text-destructive"
            title={t(ORDERS_TEXTS.delete)}
            aria-label={t(ORDERS_TEXTS.delete)}
            onClick={() => onDelete(order)}
          >
            <Trash2 className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
