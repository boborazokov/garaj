import { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { ADMIN_LIST_ORDERS, CLOSE_ORDER, DELETE_ORDER } from '../graphql/operations'
import type { PaginatedOrders } from '../types'
import { Pagination } from './components/Pagination'

export function AdminOrdersPage() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)

  const { data, loading, refetch } = useQuery<{ adminListOrders: PaginatedOrders }>(
    ADMIN_LIST_ORDERS,
    {
      variables: {
        pagination: { page, limit: 20 },
        search: search.trim() || undefined,
      },
    },
  )

  const [closeOrder] = useMutation(CLOSE_ORDER)
  const [removeOrder] = useMutation(DELETE_ORDER)
  const result = data?.adminListOrders

  async function onClose(id: string) {
    await closeOrder({ variables: { orderId: id } })
    refetch()
  }

  async function onDelete(id: string, title: string) {
    if (!window.confirm(`Удалить заявку «${title}»?`)) return
    await removeOrder({ variables: { orderId: id } })
    refetch()
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Заявки покупателей</h1>
        <p className="text-sm text-carbon-100">Все запросы «нужна запчасть» в маркетплейсе.</p>
      </div>

      <input
        value={search}
        onChange={(e) => {
          setSearch(e.target.value)
          setPage(1)
        }}
        onKeyDown={(e) => e.key === 'Enter' && refetch()}
        placeholder="Поиск по названию, описанию, телефону"
        className="w-full max-w-md rounded-xl border border-carbon-600 bg-carbon-800 px-4 py-2 text-white outline-none focus:border-amber-500"
      />

      {loading && <p className="text-carbon-100">Загрузка...</p>}

      <div className="overflow-x-auto rounded-2xl border border-carbon-600">
        <table className="w-full min-w-[720px] text-left text-sm">
          <thead className="bg-carbon-800 text-carbon-100">
            <tr>
              <th className="p-3">Заявка</th>
              <th className="p-3">Автор</th>
              <th className="p-3">Авто</th>
              <th className="p-3">Бюджет</th>
              <th className="p-3">Статус</th>
              <th className="p-3">Дата</th>
              <th className="p-3"></th>
            </tr>
          </thead>
          <tbody>
            {result?.payload.map((order) => (
              <tr key={order._id} className="border-t border-carbon-600">
                <td className="p-3">
                  <p className="font-medium text-white">{order.title}</p>
                  <p className="text-xs text-carbon-100">{order.phone}</p>
                </td>
                <td className="p-3 text-carbon-100">
                  {order.author?.name ?? '—'}
                  {order.author?.phone && (
                    <p className="text-xs">{order.author.phone}</p>
                  )}
                </td>
                <td className="p-3 text-carbon-100">
                  {[order.brand?.name, order.carModel?.name, order.partCategory?.name]
                    .filter(Boolean)
                    .join(' · ') || '—'}
                </td>
                <td className="p-3 text-white">
                  {order.budget
                    ? `${order.budget} ${order.currency ?? 'UZS'}`
                    : 'Договорная'}
                </td>
                <td className="p-3">
                  <span className="rounded-lg bg-carbon-700 px-2 py-1 text-xs font-semibold text-carbon-100">
                    {order.status}
                  </span>
                </td>
                <td className="p-3 text-carbon-100">
                  {order.createdAt
                    ? new Date(order.createdAt).toLocaleDateString('ru-RU')
                    : '—'}
                </td>
                <td className="p-3">
                  <div className="flex gap-3">
                    {order.status === 'ACTIVE' && (
                      <button
                        type="button"
                        onClick={() => onClose(order._id)}
                        className="text-amber-400 hover:underline"
                      >
                        Закрыть
                      </button>
                    )}
                    <button
                      type="button"
                      onClick={() => onDelete(order._id, order.title)}
                      className="text-red-400 hover:underline"
                    >
                      Удалить
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {result && (
        <Pagination page={page} totalPages={result.totalPages} onPage={setPage} />
      )}
    </div>
  )
}
