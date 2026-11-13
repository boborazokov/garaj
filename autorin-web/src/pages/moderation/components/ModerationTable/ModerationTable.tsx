import { Check, Package, X } from "lucide-react";
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
import type { Part } from "@/types";
import { MODERATION_TEXTS } from "../../constants";
import { formatPrice, formatSubmitted, skuFromId } from "../../helpers";
import type { ModerationTableProps } from "../../types";

const SKELETON_ROWS = 6;

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

export function ModerationTable({
  rows,
  loading,
  busyId,
  onApprove,
  onReject,
  onOpen,
}: ModerationTableProps) {
  const { t } = useLanguage();
  const showSkeleton = loading && rows.length === 0;

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead>{t(MODERATION_TEXTS.product)}</TableHead>
            <TableHead>{t(MODERATION_TEXTS.seller)}</TableHead>
            <TableHead>{t(MODERATION_TEXTS.category)}</TableHead>
            <TableHead>{t(MODERATION_TEXTS.price)}</TableHead>
            <TableHead>{t(MODERATION_TEXTS.submitted)}</TableHead>
            <TableHead className="text-right">{t(MODERATION_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <ModerationSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((part) => (
                <ModerationRow
                  key={part._id}
                  part={part}
                  busy={busyId === part._id}
                  onApprove={onApprove}
                  onReject={onReject}
                  onOpen={onOpen}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(MODERATION_TEXTS.empty)}
        </p>
      ) : null}
    </div>
  );
}

function ModerationSkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
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
        <Skeleton className="h-3.5 w-20" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-16" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-16" />
      </TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Skeleton className="size-8 rounded-[8px]" />
          <Skeleton className="size-8 rounded-[8px]" />
        </div>
      </TableCell>
    </TableRow>
  );
}

function ModerationRow({
  part,
  busy,
  onApprove,
  onReject,
  onOpen,
}: {
  part: Part;
  busy: boolean;
  onApprove: (part: Part) => void;
  onReject: (part: Part) => void;
  onOpen: (part: Part) => void;
}) {
  const { t, language } = useLanguage();
  const lang = language === "en" || language === "uz" ? language : "ru";
  const categoryName = part.category
    ? categoryLabel(part.category, lang)
    : "—";

  return (
    <TableRow
      className="cursor-pointer"
      onClick={() => onOpen(part)}
    >
      <TableCell>
        <div className="flex min-w-[220px] items-center gap-2.5">
          <ProductThumb src={part.images?.[0]} alt={part.name} />
          <div className="min-w-0">
            <div className="truncate font-semibold leading-tight text-foreground" title={part.name}>
              {part.name}
            </div>
            <div className="mt-0.5 text-[11px] text-muted-foreground">
              {t(MODERATION_TEXTS.sku)} {skuFromId(part._id)}
            </div>
          </div>
        </div>
      </TableCell>
      <TableCell>
        {part.seller ? (
          <div className="leading-tight">
            <div className="font-medium text-foreground">
              {part.seller.name?.trim() || "—"}
            </div>
            {part.seller.phone ? (
              <div className="mt-0.5 text-[11px] text-muted-foreground">
                {part.seller.phone}
              </div>
            ) : null}
          </div>
        ) : (
          <span className="text-muted-foreground">—</span>
        )}
      </TableCell>
      <TableCell>
        <span className="text-[13px] text-foreground">{categoryName}</span>
      </TableCell>
      <TableCell>{formatPrice(part.price, part.currency, language)}</TableCell>
      <TableCell className="text-[13px] text-muted-foreground">
        {formatSubmitted(part.createdAt, language)}
      </TableCell>
      <TableCell>
        <div
          className="flex items-center justify-end gap-1.5"
          onClick={(event) => event.stopPropagation()}
        >
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100 hover:text-emerald-800"
            title={t(MODERATION_TEXTS.approve)}
            aria-label={t(MODERATION_TEXTS.approve)}
            disabled={busy}
            onClick={() => onApprove(part)}
          >
            <Check className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-red-200 bg-red-50 text-destructive hover:bg-red-100 hover:text-destructive"
            title={t(MODERATION_TEXTS.reject)}
            aria-label={t(MODERATION_TEXTS.reject)}
            disabled={busy}
            onClick={() => onReject(part)}
          >
            <X className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
