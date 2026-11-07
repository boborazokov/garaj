import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Button } from "@/components/ui/button";
import {
  ADMIN_LIST_PARTS,
  ADMIN_LIST_USERS,
  ADMIN_SET_PART_RECOMMENDED,
  DELETE_PART,
  GET_PRODUCT_CATEGORIES,
} from "@/graphql/operations";
import { categoryLabel } from "@/lib/category-names";
import { useLanguage } from "@/lib/i18n";
import type {
  AdminPartsSort,
  CategoryRow,
  ItemStatus,
  PaginatedParts,
  PaginatedUsers,
  Part,
} from "@/types";
import {
  ConfirmDialog,
  ProductsPagination,
  ProductsTable,
  ProductsToolbar,
} from "./components";
import { PRODUCTS_PAGE_SIZE, PRODUCTS_TEXTS } from "./constants";
import { isPartRecommended, periodBounds } from "./helpers";
import type { ShowFilter } from "./types";

export function ProductsPage() {
  const { t, language } = useLanguage();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [show, setShow] = useState<ShowFilter>("all");
  const [sort, setSort] = useState<AdminPartsSort>("NEWEST");
  const [categoryId, setCategoryId] = useState("");
  const [status, setStatus] = useState<"" | ItemStatus>("");
  const [sellerId, setSellerId] = useState("");
  const [periodId, setPeriodId] = useState("");
  const [page, setPage] = useState(1);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [pendingDelete, setPendingDelete] = useState<Part[] | null>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    setPage(1);
    setSelectedIds([]);
  }, [search, show, sort, categoryId, status, sellerId, periodId]);

  const showStatus = show !== "all" && show !== "recommended" ? show : undefined;
  const resolvedStatus = status || showStatus;
  const { createdFrom, createdTo } = periodBounds(periodId);
  const canClear =
    Boolean(searchInput.trim()) ||
    show !== "all" ||
    sort !== "NEWEST" ||
    Boolean(categoryId) ||
    Boolean(status) ||
    Boolean(sellerId) ||
    Boolean(periodId);

  const { data, loading, refetch } = useQuery<{ adminListParts: PaginatedParts }>(
    ADMIN_LIST_PARTS,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        pagination: { page, limit: PRODUCTS_PAGE_SIZE },
        search: search || undefined,
        status: resolvedStatus,
        category: categoryId || undefined,
        sellerId: sellerId || undefined,
        createdFrom,
        createdTo,
        isPromoted: show === "recommended" ? true : undefined,
        sort,
      },
    },
  );

  // Product taxonomy = PART roots only (not BRAND/MODEL vehicle fitment).
  const { data: categoryData } = useQuery<{ getCategories: CategoryRow[] }>(
    GET_PRODUCT_CATEGORIES,
    { fetchPolicy: "network-only" },
  );
  const { data: usersData } = useQuery<{ adminListUsers: PaginatedUsers }>(ADMIN_LIST_USERS, {
    variables: { pagination: { page: 1, limit: 100 } },
  });

  const [removePart, { loading: deleting }] = useMutation(DELETE_PART);
  const [setRecommended] = useMutation(ADMIN_SET_PART_RECOMMENDED);

  const result = data?.adminListParts;
  const rows = result?.payload ?? [];

  const categories = useMemo(
    () =>
      (categoryData?.getCategories ?? [])
        .filter((row) => row.type === "PART" && !row.parentId)
        .map((row) => ({
          value: row._id,
          label: categoryLabel(row, language),
        })),
    [categoryData, language],
  );

  const sellers = useMemo(
    () =>
      (usersData?.adminListUsers?.payload ?? []).map((user) => ({
        value: user._id,
        label: user.name?.trim() || user.phone,
      })),
    [usersData],
  );

  function toggleAll(checked: boolean) {
    setSelectedIds(checked ? rows.map((row) => row._id) : []);
  }

  function toggleRow(id: string, checked: boolean) {
    setSelectedIds((current) =>
      checked ? Array.from(new Set([...current, id])) : current.filter((item) => item !== id),
    );
  }

  async function onRecommend(part: Part) {
    await setRecommended({
      variables: { partId: part._id, recommended: !isPartRecommended(part) },
    });
    await refetch();
  }

  async function confirmDelete() {
    if (!pendingDelete?.length) return;
    for (const part of pendingDelete) {
      await removePart({ variables: { partId: part._id } });
    }
    setPendingDelete(null);
    setSelectedIds([]);
    await refetch();
  }

  function clearFilters() {
    setSearchInput("");
    setSearch("");
    setShow("all");
    setSort("NEWEST");
    setCategoryId("");
    setStatus("");
    setSellerId("");
    setPeriodId("");
  }

  const selectedRows = rows.filter((row) => selectedIds.includes(row._id));

  return (
    <div className="flex flex-col gap-2.5">
      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <ProductsToolbar
          search={searchInput}
          show={show}
          sort={sort}
          categoryId={categoryId}
          status={status}
          sellerId={sellerId}
          periodId={periodId}
          canClear={canClear}
          categories={categories}
          sellers={sellers}
          onSearchChange={setSearchInput}
          onShowChange={setShow}
          onSortChange={setSort}
          onCategoryChange={setCategoryId}
          onStatusChange={setStatus}
          onSellerChange={setSellerId}
          onPeriodChange={setPeriodId}
          onClear={clearFilters}
        />

        <ProductsTable
          rows={rows}
          loading={loading}
          selectedIds={selectedIds}
          onToggleAll={toggleAll}
          onToggleRow={toggleRow}
          onRecommend={onRecommend}
          onDelete={(part) => setPendingDelete([part])}
        />

        {selectedRows.length > 0 ? (
          <div className="flex items-center justify-between gap-3 border-t border-border bg-slate-50 px-3 py-2 text-[13px] text-slate-700">
            <span>
              {selectedRows.length} {t(PRODUCTS_TEXTS.selected)}
            </span>
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="h-8 border-red-200 bg-red-50 text-red-600 hover:bg-red-100 hover:text-red-700"
              onClick={() => setPendingDelete(selectedRows)}
            >
              {t(PRODUCTS_TEXTS.deleteSelected)}
            </Button>
          </div>
        ) : null}

        <ProductsPagination
          page={result?.page ?? page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(PRODUCTS_TEXTS.confirmDeleteTitle)}
        message={
          (pendingDelete?.length ?? 0) > 1
            ? t(PRODUCTS_TEXTS.confirmBulkDelete)
            : t(PRODUCTS_TEXTS.confirmDelete)
        }
        confirmLabel={t(PRODUCTS_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />
    </div>
  );
}
