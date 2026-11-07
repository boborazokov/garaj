import { FolderTree, Pencil, Trash2 } from "lucide-react";
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
import type { CategoryRow } from "@/types";
import { CATEGORIES_TEXTS } from "../../constants";
import type { CategoriesTableProps } from "../../types";

const SKELETON_ROWS = 6;

function CategoryThumb({ src, alt }: { src?: string; alt: string }) {
  const url = mediaUrl(src);
  if (!url) {
    return (
      <div className="flex size-[42px] shrink-0 items-center justify-center rounded-[8px] bg-slate-100 text-muted-foreground">
        <FolderTree className="size-4" />
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

export function CategoriesTable({
  rows,
  loading,
  onEdit,
  onDelete,
}: CategoriesTableProps) {
  const { t } = useLanguage();
  const showSkeleton = loading && rows.length === 0;

  return (
    <div>
      <Table>
        <TableHeader>
          <TableRow className="hover:bg-transparent">
            <TableHead>{t(CATEGORIES_TEXTS.icon)}</TableHead>
            <TableHead>RU</TableHead>
            <TableHead>EN</TableHead>
            <TableHead>UZ</TableHead>
            <TableHead className="text-right">{t(CATEGORIES_TEXTS.action)}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {showSkeleton
            ? Array.from({ length: SKELETON_ROWS }, (_, index) => (
                <CategoriesSkeletonRow key={`skeleton-${index}`} />
              ))
            : rows.map((row) => (
                <CategoryRowItem
                  key={row._id}
                  row={row}
                  onEdit={onEdit}
                  onDelete={onDelete}
                />
              ))}
        </TableBody>
      </Table>

      {!loading && rows.length === 0 ? (
        <p className="m-0 px-4 py-9 text-center text-[13px] text-muted-foreground">
          {t(CATEGORIES_TEXTS.empty)}
        </p>
      ) : null}
    </div>
  );
}

function CategoriesSkeletonRow() {
  return (
    <TableRow className="hover:bg-transparent">
      <TableCell>
        <Skeleton className="size-[42px] rounded-[8px]" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-28" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-24" />
      </TableCell>
      <TableCell>
        <Skeleton className="h-3.5 w-24" />
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

function CategoryRowItem({
  row,
  onEdit,
  onDelete,
}: {
  row: CategoryRow;
  onEdit: (row: CategoryRow) => void;
  onDelete: (row: CategoryRow) => void;
}) {
  const { t } = useLanguage();
  const name = categoryLabel(row);

  return (
    <TableRow>
      <TableCell>
        <CategoryThumb src={row.iconUrl} alt={name} />
      </TableCell>
      <TableCell>
        <span className="font-medium text-foreground">{categoryLabel(row, "ru")}</span>
      </TableCell>
      <TableCell className="text-muted-foreground">{categoryLabel(row, "en")}</TableCell>
      <TableCell className="text-muted-foreground">{categoryLabel(row, "uz")}</TableCell>
      <TableCell>
        <div className="flex items-center justify-end gap-1.5">
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8"
            title={t(CATEGORIES_TEXTS.edit)}
            aria-label={t(CATEGORIES_TEXTS.edit)}
            onClick={() => onEdit(row)}
          >
            <Pencil className="size-3.5" />
          </Button>
          <Button
            type="button"
            variant="outline"
            size="icon"
            className="size-8 border-red-200 bg-red-50 text-destructive hover:bg-red-100 hover:text-destructive"
            title={t(CATEGORIES_TEXTS.delete)}
            aria-label={t(CATEGORIES_TEXTS.delete)}
            onClick={() => onDelete(row)}
          >
            <Trash2 className="size-3.5" />
          </Button>
        </div>
      </TableCell>
    </TableRow>
  );
}
