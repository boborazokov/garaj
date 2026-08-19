import { useEffect, useState } from 'react'
import { useQuery } from '@apollo/client/react'
import { Link } from 'react-router-dom'
import { ADMIN_LIST_PARTS } from '../graphql/operations'
import type { CategoryType, PaginatedParts } from '../types'
import { Pagination } from './components/Pagination'
import { mediaUrl } from '../lib/media'

const statusLabel: Record<string, string> = {
  ACTIVE: 'Активен',
  ARCHIVED: 'Архив',
  PENDING_MODERATION: 'На проверке',
  REJECTED: 'Отклонён',
}

type ListingTab = 'ALL' | CategoryType

const TABS: { id: ListingTab; label: string }[] = [
  { id: 'ALL', label: 'Все' },
  { id: 'PART', label: 'Запчасти' },
  { id: 'SERVICE', label: 'Услуги' },
  { id: 'TUNING', label: 'Тюнинг' },
]

export function AdminPartsPage() {
  const [page, setPage] = useState(1)
  const [search, setSearch] = useState('')
  const [submitted, setSubmitted] = useState('')
  const [tab, setTab] = useState<ListingTab>('ALL')

  useEffect(() => {
    setPage(1)
  }, [tab, submitted])

  const { data, loading } = useQuery<{ adminListParts: PaginatedParts }>(ADMIN_LIST_PARTS, {
    variables: {
      pagination: { page, limit: 20 },
      search: submitted || undefined,
      categoryType: tab === 'ALL' ? undefined : tab,
    },
  })

  const result = data?.adminListParts

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">Объявления</h1>
        <p className="text-sm text-carbon-100">
          Запчасти, услуги, тюнинг и другие публикации пользователей.
        </p>
      </div>

      <div className="flex flex-wrap gap-2">
        {TABS.map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => setTab(t.id)}
            className={`rounded-xl px-3 py-1.5 text-sm font-medium ${
              tab === t.id
                ? 'bg-amber-500 text-white'
                : 'bg-carbon-800 text-carbon-100 hover:bg-carbon-700'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      <form
        className="flex max-w-md gap-2"
        onSubmit={(e) => {
          e.preventDefault()
          setSubmitted(search.trim())
        }}
      >
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Поиск по названию"
          className="flex-1 rounded-xl border border-carbon-600 bg-carbon-800 px-4 py-2 text-white outline-none focus:border-amber-500"
        />
        <button
          type="submit"
          className="rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white"
        >
          Найти
        </button>
      </form>

      {loading && <p className="text-carbon-100">Загрузка...</p>}

      <div className="overflow-x-auto rounded-2xl border border-carbon-600">
        <table className="w-full min-w-[720px] text-left text-sm">
          <thead className="bg-carbon-800 text-carbon-100">
            <tr>
              <th className="p-3">Фото</th>
              <th className="p-3">Название</th>
              <th className="p-3">Тип</th>
              <th className="p-3">Цена</th>
              <th className="p-3">Статус</th>
              <th className="p-3">Продавец</th>
              <th className="p-3"></th>
            </tr>
          </thead>
          <tbody>
            {result?.payload.map((part) => (
              <tr key={part._id} className="border-t border-carbon-600">
                <td className="p-3">
                  <img
                    src={mediaUrl(part.images?.[0])}
                    alt=""
                    className="h-12 w-12 rounded-lg object-cover bg-carbon-700"
                  />
                </td>
                <td className="p-3 font-medium text-white">{part.name}</td>
                <td className="p-3 text-carbon-100">{part.category?.name ?? '—'}</td>
                <td className="p-3 text-carbon-100">
                  {part.price} {part.currency}
                </td>
                <td className="p-3">
                  <span className="rounded-full bg-carbon-700 px-2 py-0.5 text-xs">
                    {statusLabel[part.status] ?? part.status}
                  </span>
                </td>
                <td className="p-3 text-carbon-100">{part.seller?.name}</td>
                <td className="p-3">
                  <Link
                    to={`/admin/parts/${part._id}`}
                    className="text-amber-400 hover:underline"
                  >
                    Открыть
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {!loading && result?.payload.length === 0 && (
        <p className="text-center text-carbon-100">Ничего не найдено</p>
      )}

      {result && (
        <Pagination page={page} totalPages={result.totalPages} onPage={setPage} />
      )}
    </div>
  )
}
