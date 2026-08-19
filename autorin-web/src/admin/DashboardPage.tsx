import { useState } from 'react'
import { useQuery } from '@apollo/client/react'
import {
  Bar,
  BarChart,
  CartesianGrid,
  Legend,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts'
import { GET_ADMIN_DAILY_REPORT, GET_ADMIN_STATS } from '../graphql/operations'
import type { AdminDailyReport, AdminStats } from '../types'

const PERIODS = [
  { label: '7 дней', days: 7 },
  { label: '14 дней', days: 14 },
  { label: '30 дней', days: 30 },
] as const

function formatChartDate(iso: string) {
  const [, m, d] = iso.split('-')
  return `${d}.${m}`
}

export function AdminDashboardPage() {
  const [days, setDays] = useState(14)

  const { data: statsData, loading: statsLoading } = useQuery<{ getAdminStats: AdminStats }>(
    GET_ADMIN_STATS,
  )
  const { data: reportData, loading: reportLoading } = useQuery<{
    getAdminDailyReport: AdminDailyReport
  }>(GET_ADMIN_DAILY_REPORT, { variables: { days } })

  const stats = statsData?.getAdminStats
  const report = reportData?.getAdminDailyReport

  const chartData =
    report?.rows.map((r) => ({
      ...r,
      label: formatChartDate(r.date),
    })) ?? []

  const summaryCards = [
    { label: 'Сегодня зашли', value: report?.todayVisits, accent: true },
    { label: 'Сегодня товаров', value: report?.todayPartsPublished, accent: true },
    { label: `Визиты за ${days} дн.`, value: report?.totalVisits },
    { label: `Новые рег. за ${days} дн.`, value: report?.totalNewUsers },
    { label: `Товары за ${days} дн.`, value: report?.totalPartsPublished },
    { label: `Заявки за ${days} дн.`, value: report?.totalOrdersPublished },
  ]

  const totalsCards = [
    { label: 'Всего пользователей', value: stats?.usersCount },
    { label: 'Все товары', value: stats?.partsCount },
    { label: 'Активные товары', value: stats?.activePartsCount },
    { label: 'На модерации', value: stats?.pendingModerationCount },
    { label: 'Всего заявок', value: stats?.ordersCount },
  ]

  return (
    <div className="space-y-8">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <h1 className="text-2xl font-bold text-white">Отчёты</h1>
        <div className="flex rounded-xl bg-carbon-800 p-1">
          {PERIODS.map((p) => (
            <button
              key={p.days}
              type="button"
              onClick={() => setDays(p.days)}
              className={`rounded-lg px-3 py-1.5 text-sm font-medium transition ${
                days === p.days
                  ? 'bg-amber-500 text-white'
                  : 'text-carbon-100 hover:text-white'
              }`}
            >
              {p.label}
            </button>
          ))}
        </div>
      </div>

      {reportLoading && !report ? (
        <p className="text-carbon-100">Загрузка отчёта...</p>
      ) : (
        <>
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {summaryCards.map((c) => (
              <div
                key={c.label}
                className={`rounded-2xl border p-5 ${
                  c.accent
                    ? 'border-amber-500/40 bg-amber-500/10'
                    : 'border-carbon-600 bg-carbon-800'
                }`}
              >
                <p className="text-sm text-carbon-100">{c.label}</p>
                <p className="mt-1 text-3xl font-bold text-amber-400">{c.value ?? '—'}</p>
              </div>
            ))}
          </div>

          <div className="rounded-2xl border border-carbon-600 bg-carbon-800 p-4 md:p-6">
            <h2 className="mb-4 text-lg font-semibold text-white">
              Визиты и публикации по дням
            </h2>
            <div className="h-72 w-full min-w-0">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData} margin={{ top: 8, right: 8, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#2a3441" />
                  <XAxis dataKey="label" tick={{ fill: '#b8c2d0', fontSize: 11 }} />
                  <YAxis tick={{ fill: '#b8c2d0', fontSize: 11 }} allowDecimals={false} />
                  <Tooltip
                    contentStyle={{
                      background: '#141a22',
                      border: '1px solid #2a3441',
                      borderRadius: 12,
                    }}
                    labelFormatter={(_, payload) =>
                      payload?.[0]?.payload?.date
                        ? `Дата: ${payload[0].payload.date}`
                        : ''
                    }
                  />
                  <Legend />
                  <Bar dataKey="visits" name="Визиты" fill="#f59e0b" radius={[4, 4, 0, 0]} />
                  <Bar
                    dataKey="partsPublished"
                    name="Товары"
                    fill="#16a34a"
                    radius={[4, 4, 0, 0]}
                  />
                  <Bar
                    dataKey="ordersPublished"
                    name="Заявки"
                    fill="#2563eb"
                    radius={[4, 4, 0, 0]}
                  />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="overflow-x-auto rounded-2xl border border-carbon-600">
            <table className="w-full min-w-[640px] text-left text-sm">
              <thead className="bg-carbon-800 text-carbon-100">
                <tr>
                  <th className="p-3">Дата</th>
                  <th className="p-3">Визиты (уник.)</th>
                  <th className="p-3">Новые рег.</th>
                  <th className="p-3">Товары</th>
                  <th className="p-3">Заявки</th>
                </tr>
              </thead>
              <tbody>
                {[...(report?.rows ?? [])].reverse().map((row) => (
                  <tr key={row.date} className="border-t border-carbon-600 text-white">
                    <td className="p-3 font-medium">{row.date}</td>
                    <td className="p-3">{row.visits}</td>
                    <td className="p-3">{row.newUsers}</td>
                    <td className="p-3">{row.partsPublished}</td>
                    <td className="p-3">{row.ordersPublished}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}

      <section>
        <h2 className="mb-4 text-lg font-semibold text-white">Сводка платформы</h2>
        {statsLoading ? (
          <p className="text-carbon-100">Загрузка...</p>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-5">
            {totalsCards.map((c) => (
              <div
                key={c.label}
                className="rounded-2xl border border-carbon-600 bg-carbon-800 p-4"
              >
                <p className="text-xs text-carbon-100">{c.label}</p>
                <p className="mt-1 text-2xl font-bold text-white">{c.value ?? '—'}</p>
              </div>
            ))}
          </div>
        )}
      </section>

      <p className="text-xs text-carbon-500">
        Визиты: уникальные пользователи в день (вход, регистрация, активность в приложении).
        Товары и заявки — по дате создания. Часовой пояс: Asia/Tashkent (UTC+5).
      </p>
    </div>
  )
}
