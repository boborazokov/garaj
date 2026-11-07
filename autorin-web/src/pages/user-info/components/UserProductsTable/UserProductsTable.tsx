import { Package } from "lucide-react";
import { Badge } from "@/components/ui/badge";
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
import type { ItemStatus } from "@/types";
import { STATUS_LABELS, USER_INFO_COLORS, USER_INFO_TEXTS } from "../../constants";
import { formatPrice, formatProductDate } from "../../helpers";
import type { UserProductsTableProps } from "../../types";

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

export function UserProductsTable({ rows, loading }: UserProductsTableProps) {
  const { t, language } = useLanguage();
  const showSkeleton = loading && rows.length === 0;

  return (
    <div
      className="overflow-hidden rounded-[10px] border bg-white"
      style={{ borderColor: USER_INFO_COLORS.border }}
    >
      <div className="border-b px-4 py-3" style={{ borderColor: USER_INFO_COLORS.border }}>
        <h2
          className="text-[14px] font-semibold"
          style={{ color: USER_INFO_COLORS.text }}
        >
          {t(USER_INFO_TEXTS.productsTitle)}
        </h2>
        <p className="mt-0.5 text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
          {t(USER_INFO_TEXTS.productsSubtitle)}
        </p>
      </div>

      {showSkeleton ? (
        <div className="space-y-3 p-4">
          {Array.from({ length: 4 }).map((_, index) => (
            <Skeleton key={index} className="h-12 w-full rounded-md" />
          ))}
        </div>
      ) : rows.length === 0 ? (
        <p className="px-4 py-10 text-center text-sm" style={{ color: USER_INFO_COLORS.muted }}>
          {t(USER_INFO_TEXTS.emptyProducts)}
        </p>
      ) : (
        <Table>
          <TableHeader>
            <TableRow className="hover:bg-transparent">
              <TableHead>{t(USER_INFO_TEXTS.product)}</TableHead>
              <TableHead>{t(USER_INFO_TEXTS.category)}</TableHead>
              <TableHead>{t(USER_INFO_TEXTS.price)}</TableHead>
              <TableHead>{t(USER_INFO_TEXTS.status)}</TableHead>
              <TableHead>{t(USER_INFO_TEXTS.views)}</TableHead>
              <TableHead>{t(USER_INFO_TEXTS.createdAt)}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {rows.map((row) => {
              const status = row.status as ItemStatus;
              const date = formatProductDate(row.createdAt, language);
              return (
                <TableRow key={row._id}>
                  <TableCell>
                    <div className="flex min-w-0 items-center gap-2.5">
                      <ProductThumb src={row.images?.[0]} alt={row.name} />
                      <span
                        className="truncate font-medium"
                        style={{ color: USER_INFO_COLORS.text }}
                      >
                        {row.name}
                      </span>
                    </div>
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {row.category ? categoryLabel(row.category, language) : "—"}
                  </TableCell>
                  <TableCell className="whitespace-nowrap font-medium">
                    {formatPrice(row.price, row.currency, language)}
                  </TableCell>
                  <TableCell>
                    <Badge variant={STATUS_BADGE[status] ?? "muted"}>
                      {t(STATUS_LABELS[status] ?? STATUS_LABELS.ARCHIVED)}
                    </Badge>
                  </TableCell>
                  <TableCell className="text-muted-foreground">
                    {(row.viewsCount ?? 0).toLocaleString(
                      language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU",
                    )}
                  </TableCell>
                  <TableCell className="whitespace-nowrap text-muted-foreground">
                    {date}
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      )}
    </div>
  );
}
