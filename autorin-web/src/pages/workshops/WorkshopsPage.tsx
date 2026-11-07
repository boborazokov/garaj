import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Button } from "@/components/ui/button";
import {
  ADMIN_LIST_USERS,
  ADMIN_LIST_WORKSHOPS,
  ADMIN_SET_WORKSHOP_RECOMMENDED,
  DELETE_WORKSHOP,
  WORKSHOP_CATEGORIES,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type {
  AdminWorkshopsSort,
  ItemStatus,
  PaginatedUsers,
  PaginatedWorkshops,
  WorkshopCategoryRef,
  WorkshopRow,
} from "@/types";
import {
  ConfirmDialog,
  WorkshopsPagination,
  WorkshopsTable,
  WorkshopsToolbar,
} from "./components";
import { WORKSHOPS_PAGE_SIZE, WORKSHOPS_TEXTS } from "./constants";
import { isWorkshopRecommended, periodBounds, workshopCategoryLabel } from "./helpers";
import type { ShowFilter } from "./types";

export function WorkshopsPage() {
  const { t, language } = useLanguage();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [show, setShow] = useState<ShowFilter>("all");
  const [sort, setSort] = useState<AdminWorkshopsSort>("NEWEST");
  const [categoryId, setCategoryId] = useState("");
  const [status, setStatus] = useState<"" | ItemStatus>("");
  const [ownerId, setOwnerId] = useState("");
  const [periodId, setPeriodId] = useState("");
  const [page, setPage] = useState(1);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [pendingDelete, setPendingDelete] = useState<WorkshopRow[] | null>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    setPage(1);
    setSelectedIds([]);
  }, [search, show, sort, categoryId, status, ownerId, periodId]);

  const showStatus = show !== "all" && show !== "recommended" ? show : undefined;
  const resolvedStatus = status || showStatus;
  const { createdFrom, createdTo } = periodBounds(periodId);
  const canClear =
    Boolean(searchInput.trim()) ||
    show !== "all" ||
    sort !== "NEWEST" ||
    Boolean(categoryId) ||
    Boolean(status) ||
    Boolean(ownerId) ||
    Boolean(periodId);

  const { data, loading, refetch } = useQuery<{ adminListWorkshops: PaginatedWorkshops }>(
    ADMIN_LIST_WORKSHOPS,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        pagination: { page, limit: WORKSHOPS_PAGE_SIZE },
        search: search || undefined,
        status: resolvedStatus,
        categoryId: categoryId || undefined,
        ownerId: ownerId || undefined,
        createdFrom,
        createdTo,
        isPromoted: show === "recommended" ? true : undefined,
        sort,
      },
    },
  );

  const { data: categoryData } = useQuery<{ workshopCategories: WorkshopCategoryRef[] }>(
    WORKSHOP_CATEGORIES,
    { fetchPolicy: "network-only" },
  );
  const { data: usersData } = useQuery<{ adminListUsers: PaginatedUsers }>(ADMIN_LIST_USERS, {
    variables: { pagination: { page: 1, limit: 100 } },
  });

  const [removeWorkshop, { loading: deleting }] = useMutation(DELETE_WORKSHOP);
  const [setRecommended] = useMutation(ADMIN_SET_WORKSHOP_RECOMMENDED);

  const result = data?.adminListWorkshops;
  const rows = result?.payload ?? [];

  const categories = useMemo(
    () =>
      (categoryData?.workshopCategories ?? [])
        .map((row) => ({
          value: String(row._id),
          label: workshopCategoryLabel(row, language) || row.slug || String(row._id),
        }))
        .filter((row) => Boolean(row.label.trim())),
    [categoryData, language],
  );

  const owners = useMemo(
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

  async function onRecommend(workshop: WorkshopRow) {
    await setRecommended({
      variables: {
        workshopId: workshop._id,
        recommended: !isWorkshopRecommended(workshop),
      },
    });
    await refetch();
  }

  async function confirmDelete() {
    if (!pendingDelete?.length) return;
    for (const workshop of pendingDelete) {
      await removeWorkshop({ variables: { workshopId: workshop._id } });
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
    setOwnerId("");
    setPeriodId("");
  }

  const selectedRows = rows.filter((row) => selectedIds.includes(row._id));

  return (
    <div className="flex flex-col gap-2.5">
      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <WorkshopsToolbar
          search={searchInput}
          show={show}
          sort={sort}
          categoryId={categoryId}
          status={status}
          ownerId={ownerId}
          periodId={periodId}
          canClear={canClear}
          categories={categories}
          owners={owners}
          onSearchChange={setSearchInput}
          onShowChange={setShow}
          onSortChange={setSort}
          onCategoryChange={setCategoryId}
          onStatusChange={setStatus}
          onOwnerChange={setOwnerId}
          onPeriodChange={setPeriodId}
          onClear={clearFilters}
        />

        <WorkshopsTable
          rows={rows}
          loading={loading}
          selectedIds={selectedIds}
          onToggleAll={toggleAll}
          onToggleRow={toggleRow}
          onRecommend={onRecommend}
          onDelete={(workshop) => setPendingDelete([workshop])}
        />

        {selectedRows.length > 0 ? (
          <div className="flex items-center justify-between gap-3 border-t border-border bg-slate-50 px-3 py-2 text-[13px] text-slate-700">
            <span>
              {selectedRows.length} {t(WORKSHOPS_TEXTS.selected)}
            </span>
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="h-8 border-red-200 bg-red-50 text-red-600 hover:bg-red-100 hover:text-red-700"
              onClick={() => setPendingDelete(selectedRows)}
            >
              {t(WORKSHOPS_TEXTS.deleteSelected)}
            </Button>
          </div>
        ) : null}

        <WorkshopsPagination
          page={result?.page ?? page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(WORKSHOPS_TEXTS.confirmDeleteTitle)}
        message={
          (pendingDelete?.length ?? 0) > 1
            ? t(WORKSHOPS_TEXTS.confirmBulkDelete)
            : t(WORKSHOPS_TEXTS.confirmDelete)
        }
        confirmLabel={t(WORKSHOPS_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />
    </div>
  );
}
