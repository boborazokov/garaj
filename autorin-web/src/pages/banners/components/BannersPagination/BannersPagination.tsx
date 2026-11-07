import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationLink,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { useLanguage } from "@/lib/i18n";
import { BANNERS_TEXTS } from "../../constants";
import type { BannersPaginationProps } from "../../types";

function pageItems(page: number, totalPages: number) {
  if (totalPages <= 7) {
    return Array.from({ length: totalPages }, (_, index) => index + 1);
  }

  const items: Array<number | "ellipsis"> = [1];
  const start = Math.max(2, page - 1);
  const end = Math.min(totalPages - 1, page + 1);

  if (start > 2) items.push("ellipsis");
  for (let value = start; value <= end; value += 1) items.push(value);
  if (end < totalPages - 1) items.push("ellipsis");
  items.push(totalPages);
  return items;
}

export function BannersPagination({ page, totalPages, onPage }: BannersPaginationProps) {
  const { t } = useLanguage();
  if (totalPages <= 1) return null;

  return (
    <Pagination className="border-t border-border py-3">
      <PaginationContent>
        <PaginationItem>
          <PaginationPrevious
            disabled={page <= 1}
            aria-label={t(BANNERS_TEXTS.prevPage)}
            onClick={() => onPage(page - 1)}
          />
        </PaginationItem>
        {pageItems(page, totalPages).map((item, index) =>
          item === "ellipsis" ? (
            <PaginationItem key={`e-${index}`}>
              <PaginationEllipsis />
            </PaginationItem>
          ) : (
            <PaginationItem key={item}>
              <PaginationLink isActive={item === page} onClick={() => onPage(item)}>
                {item}
              </PaginationLink>
            </PaginationItem>
          ),
        )}
        <PaginationItem>
          <PaginationNext
            disabled={page >= totalPages}
            aria-label={t(BANNERS_TEXTS.nextPage)}
            onClick={() => onPage(page + 1)}
          />
        </PaginationItem>
      </PaginationContent>
    </Pagination>
  );
}
