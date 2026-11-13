import { useEffect, useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Button } from "@/components/ui/button";
import {
  ADMIN_LIST_ORDERS,
  ADMIN_LIST_USERS,
  ADMIN_SET_ORDER_RECOMMENDED,
  CLOSE_ORDER,
  DELETE_ORDER,
  GET_PRODUCT_CATEGORIES,
  PROMOTION_PLAN_PRICES,
  REOPEN_ORDER,
} from "@/graphql/operations";
import { categoryLabel } from "@/lib/category-names";
import { useLanguage } from "@/lib/i18n";
import type {
  AdminOrdersSort,
  CategoryRow,
  OrderRow,
  OrderStatus,
  PaginatedOrders,
  PaginatedUsers,
  PromotionPlan,
  PromotionPlanPrice,
} from "@/types";
import { PromotePlanDialog } from "@/pages/products/components/PromotePlanDialog";
import {
  ConfirmDialog,
  OffersDialog,
  OrdersPagination,
  OrdersTable,
  OrdersToolbar,
  StatsDialog,
} from "./components";
import { ORDERS_PAGE_SIZE, ORDERS_TEXTS } from "./constants";
import { isOrderRecommended, periodBounds } from "./helpers";
import type { ShowFilter } from "./types";

export function OrdersPage() {
  const { t, language } = useLanguage();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [show, setShow] = useState<ShowFilter>("all");
  const [sort, setSort] = useState<AdminOrdersSort>("NEWEST");
  const [categoryId, setCategoryId] = useState("");
  const [status, setStatus] = useState<"" | OrderStatus>("");
  const [authorId, setAuthorId] = useState("");
  const [periodId, setPeriodId] = useState("");
  const [page, setPage] = useState(1);
  const [selectedIds, setSelectedIds] = useState<string[]>([]);
  const [pendingDelete, setPendingDelete] = useState<OrderRow[] | null>(null);
  const [pendingClose, setPendingClose] = useState<OrderRow | null>(null);
  const [pendingReopen, setPendingReopen] = useState<OrderRow | null>(null);
  const [offersOrder, setOffersOrder] = useState<OrderRow | null>(null);
  const [pendingPromote, setPendingPromote] = useState<OrderRow | null>(null);
  const [promoteError, setPromoteError] = useState<string | null>(null);
  const [promoting, setPromoting] = useState(false);
  const [statsOrder, setStatsOrder] = useState<OrderRow | null>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    setPage(1);
    setSelectedIds([]);
  }, [search, show, sort, categoryId, status, authorId, periodId]);

  const showStatus = show !== "all" && show !== "recommended" ? show : undefined;
  const resolvedStatus = status || showStatus;
  const { createdFrom, createdTo } = periodBounds(periodId);
  const canClear =
    Boolean(searchInput.trim()) ||
    show !== "all" ||
    sort !== "NEWEST" ||
    Boolean(categoryId) ||
    Boolean(status) ||
    Boolean(authorId) ||
    Boolean(periodId);

  const { data, loading, refetch } = useQuery<{ adminListOrders: PaginatedOrders }>(
    ADMIN_LIST_ORDERS,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        pagination: { page, limit: ORDERS_PAGE_SIZE },
        search: search || undefined,
        status: resolvedStatus,
        partCategoryId: categoryId || undefined,
        authorId: authorId || undefined,
        createdFrom,
        createdTo,
        isPromoted: show === "recommended" ? true : undefined,
        sort,
      },
    },
  );

  const { data: categoryData } = useQuery<{ getCategories: CategoryRow[] }>(
    GET_PRODUCT_CATEGORIES,
    { fetchPolicy: "network-only" },
  );
  const { data: usersData } = useQuery<{ adminListUsers: PaginatedUsers }>(ADMIN_LIST_USERS, {
    variables: { pagination: { page: 1, limit: 100 } },
  });

  const [removeOrder, { loading: deleting }] = useMutation(DELETE_ORDER);
  const [closeOrder, { loading: closing }] = useMutation(CLOSE_ORDER);
  const [reopenOrder, { loading: reopening }] = useMutation(REOPEN_ORDER);
  const [setRecommended] = useMutation(ADMIN_SET_ORDER_RECOMMENDED);
  const { data: planData } = useQuery<{
    promotionPlanPrices: PromotionPlanPrice[];
  }>(PROMOTION_PLAN_PRICES, {
    fetchPolicy: "cache-and-network",
    skip: !pendingPromote,
  });

  const result = data?.adminListOrders;
  const rows = result?.payload ?? [];
  const planPrices = planData?.promotionPlanPrices ?? [];

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

  const authors = useMemo(
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

  async function onRecommend(order: OrderRow) {
    if (isOrderRecommended(order)) {
      await setRecommended({
        variables: { orderId: order._id, recommended: false },
      });
      await refetch();
      return;
    }
    setPromoteError(null);
    setPendingPromote(order);
  }

  async function confirmPromote(plan: PromotionPlan) {
    if (!pendingPromote) return;
    setPromoting(true);
    setPromoteError(null);
    try {
      await setRecommended({
        variables: {
          orderId: pendingPromote._id,
          recommended: true,
          plan,
        },
      });
      setPendingPromote(null);
      await refetch();
    } catch (err) {
      setPromoteError(
        err instanceof Error
          ? err.message
          : t({
              uz: "Tarifni tanlash majburiy",
              ru: "Нужно выбрать тариф",
              en: "A tariff is required",
            }),
      );
    } finally {
      setPromoting(false);
    }
  }

  async function confirmDelete() {
    if (!pendingDelete?.length) return;
    for (const order of pendingDelete) {
      await removeOrder({ variables: { orderId: order._id } });
    }
    setPendingDelete(null);
    setSelectedIds([]);
    await refetch();
  }

  async function confirmClose() {
    if (!pendingClose) return;
    await closeOrder({ variables: { orderId: pendingClose._id } });
    setPendingClose(null);
    await refetch();
  }

  async function confirmReopen() {
    if (!pendingReopen) return;
    await reopenOrder({ variables: { orderId: pendingReopen._id } });
    setPendingReopen(null);
    await refetch();
  }

  function clearFilters() {
    setSearchInput("");
    setSearch("");
    setShow("all");
    setSort("NEWEST");
    setCategoryId("");
    setStatus("");
    setAuthorId("");
    setPeriodId("");
  }

  const selectedRows = rows.filter((row) => selectedIds.includes(row._id));

  return (
    <div className="flex flex-col gap-2.5">
      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <OrdersToolbar
          search={searchInput}
          show={show}
          sort={sort}
          categoryId={categoryId}
          status={status}
          authorId={authorId}
          periodId={periodId}
          canClear={canClear}
          categories={categories}
          authors={authors}
          onSearchChange={setSearchInput}
          onShowChange={setShow}
          onSortChange={setSort}
          onCategoryChange={setCategoryId}
          onStatusChange={setStatus}
          onAuthorChange={setAuthorId}
          onPeriodChange={setPeriodId}
          onClear={clearFilters}
        />

        <OrdersTable
          rows={rows}
          loading={loading}
          selectedIds={selectedIds}
          onToggleAll={toggleAll}
          onToggleRow={toggleRow}
          onRecommend={onRecommend}
          onOffers={setOffersOrder}
          onClose={setPendingClose}
          onReopen={setPendingReopen}
          onDelete={(order) => setPendingDelete([order])}
          onOpenStats={setStatsOrder}
        />

        {selectedRows.length > 0 ? (
          <div className="flex items-center justify-between gap-3 border-t border-border bg-slate-50 px-3 py-2 text-[13px] text-slate-700">
            <span>
              {selectedRows.length} {t(ORDERS_TEXTS.selected)}
            </span>
            <Button
              type="button"
              variant="outline"
              size="sm"
              className="h-8 border-red-200 bg-red-50 text-red-600 hover:bg-red-100 hover:text-red-700"
              onClick={() => setPendingDelete(selectedRows)}
            >
              {t(ORDERS_TEXTS.deleteSelected)}
            </Button>
          </div>
        ) : null}

        <OrdersPagination
          page={result?.page ?? page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(ORDERS_TEXTS.confirmDeleteTitle)}
        message={
          (pendingDelete?.length ?? 0) > 1
            ? t(ORDERS_TEXTS.confirmBulkDelete)
            : t(ORDERS_TEXTS.confirmDelete)
        }
        confirmLabel={t(ORDERS_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />

      <ConfirmDialog
        open={Boolean(pendingClose)}
        title={t(ORDERS_TEXTS.confirmCloseTitle)}
        message={t(ORDERS_TEXTS.confirmClose)}
        confirmLabel={t(ORDERS_TEXTS.closeOrder)}
        busy={closing}
        onCancel={() => setPendingClose(null)}
        onConfirm={() => {
          void confirmClose();
        }}
      />

      <ConfirmDialog
        open={Boolean(pendingReopen)}
        title={t(ORDERS_TEXTS.confirmReopenTitle)}
        message={t(ORDERS_TEXTS.confirmReopen)}
        confirmLabel={t(ORDERS_TEXTS.reopenOrder)}
        busy={reopening}
        onCancel={() => setPendingReopen(null)}
        onConfirm={() => {
          void confirmReopen();
        }}
      />

      <OffersDialog
        order={offersOrder}
        open={Boolean(offersOrder)}
        onClose={() => setOffersOrder(null)}
      />

      <StatsDialog
        order={statsOrder}
        open={Boolean(statsOrder)}
        onClose={() => setStatsOrder(null)}
      />

      <PromotePlanDialog
        open={Boolean(pendingPromote)}
        partName={pendingPromote?.title}
        prices={planPrices}
        busy={promoting}
        error={promoteError}
        onCancel={() => {
          if (promoting) return;
          setPendingPromote(null);
          setPromoteError(null);
        }}
        onConfirm={(plan) => {
          void confirmPromote(plan);
        }}
      />
    </div>
  );
}
