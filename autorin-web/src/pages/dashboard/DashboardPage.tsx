import { useMemo, useState } from "react";
import { useQuery } from "@apollo/client/react";
import { ClipboardList, Eye, Package, ShieldAlert, TrendingUp, Users } from "lucide-react";
import { GET_ADMIN_DAILY_REPORT, GET_ADMIN_STATS } from "@/graphql/operations";
import { getUser } from "@/lib/auth";
import type { AdminDailyReport, AdminStats } from "@/types";
import { GreetingBar, PlatformStrip, SnapshotCards, VisitsChart } from "./components";
import { DASHBOARD_TEXTS } from "./constants";
import { periodTrend } from "./helpers";
import type { ChartMetric } from "./types";

export function DashboardPage() {
  const user = getUser();
  const [days, setDays] = useState(30);
  const [metric, setMetric] = useState<ChartMetric>("visits");

  const { data: statsData, loading: statsLoading } = useQuery<{ getAdminStats: AdminStats }>(
    GET_ADMIN_STATS,
    { fetchPolicy: "cache-and-network" },
  );
  const { data: reportData, loading: reportLoading } = useQuery<{
    getAdminDailyReport: AdminDailyReport;
  }>(GET_ADMIN_DAILY_REPORT, {
    variables: { days },
    fetchPolicy: "cache-and-network",
  });

  const stats = statsData?.getAdminStats;
  const report = reportData?.getAdminDailyReport;
  const rows = report?.rows ?? [];

  const snapshotCards = useMemo(
    () => [
      {
        label: DASHBOARD_TEXTS.visitsToday,
        value: report?.todayVisits,
        icon: Eye,
      },
      {
        label: DASHBOARD_TEXTS.partsToday,
        value: report?.todayPartsPublished,
        icon: Package,
      },
      {
        label: DASHBOARD_TEXTS.pending,
        value: stats?.pendingModerationCount,
        icon: ShieldAlert,
      },
      {
        label: DASHBOARD_TEXTS.users,
        value: stats?.usersCount,
        icon: Users,
      },
    ],
    [report, stats],
  );

  const periodCards = useMemo(
    () => [
      {
        label: DASHBOARD_TEXTS.visitsPeriod,
        value: report?.totalVisits,
        icon: TrendingUp,
        trend: periodTrend(rows, (row) => row.visits),
      },
      {
        label: DASHBOARD_TEXTS.partsPeriod,
        value: report?.totalPartsPublished,
        icon: Package,
        trend: periodTrend(rows, (row) => row.partsPublished),
      },
      {
        label: DASHBOARD_TEXTS.ordersPeriod,
        value: report?.totalOrdersPublished,
        icon: ClipboardList,
        trend: periodTrend(rows, (row) => row.ordersPublished),
      },
    ],
    [report, rows],
  );

  const platformItems = useMemo(
    () => [
      { labelKey: "activeParts" as const, value: stats?.activePartsCount },
      { labelKey: "allParts" as const, value: stats?.partsCount },
      { labelKey: "workshops" as const, value: stats?.workshopsCount },
      { labelKey: "activeWorkshops" as const, value: stats?.activeWorkshopsCount },
      { labelKey: "allOrders" as const, value: stats?.ordersCount },
    ],
    [stats],
  );

  const chartTotal =
    metric === "visits"
      ? report?.totalVisits
      : metric === "partsPublished"
        ? report?.totalPartsPublished
        : report?.totalOrdersPublished;

  return (
    <div className="flex flex-col gap-4">
      <GreetingBar
        userName={user?.name || "Admin"}
        days={days}
        onDaysChange={setDays}
      />

      <SnapshotCards cards={snapshotCards} loading={statsLoading || reportLoading} />
      <SnapshotCards cards={periodCards} loading={reportLoading} columns={3} />
      <VisitsChart
        rows={rows}
        metric={metric}
        total={chartTotal}
        onMetricChange={setMetric}
        loading={reportLoading}
      />
      <PlatformStrip items={platformItems} loading={statsLoading} />
    </div>
  );
}
