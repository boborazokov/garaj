import { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { APPROVE_PART, GET_PENDING_PARTS, REJECT_PART } from '../graphql/operations'
import type { PaginatedParts, Part } from '../types'
import { mediaUrl } from '../lib/media'
import { Check, X } from 'lucide-react'

export function ModeratorQueuePage() {
  const [page, setPage] = useState(1)
  const [rejectId, setRejectId] = useState<string | null>(null)
  const [rejectNote, setRejectNote] = useState('')

  const { data, loading, refetch } = useQuery<{ getPendingParts: PaginatedParts }>(
    GET_PENDING_PARTS,
    { variables: { pagination: { page, limit: 10 } } },
  )

  const [approve] = useMutation(APPROVE_PART)
  const [reject, { loading: rejecting }] = useMutation(REJECT_PART)

  const result = data?.getPendingParts

  async function handleApprove(part: Part) {
    await approve({ variables: { partId: part._id } })
    refetch()
  }

  async function handleReject(partId: string) {
    if (!rejectNote.trim()) return
    await reject({ variables: { partId, note: rejectNote.trim() } })
    setRejectId(null)
    setRejectNote('')
    refetch()
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-lg font-semibold">Очередь проверки</h2>
        <p className="text-sm text-carbon-600">
          Новые товары, ожидающие одобрения (когда модерация включена в админке).
        </p>
      </div>

      {loading && <p>Загрузка...</p>}

      {!loading && result?.payload.length === 0 && (
        <p className="rounded-2xl border border-carbon-100 bg-white p-8 text-center text-carbon-600">
          Очередь пуста — нет товаров на проверке.
        </p>
      )}

      <div className="space-y-4">
        {result?.payload.map((part) => (
          <article
            key={part._id}
            className="flex flex-col gap-4 rounded-2xl border border-carbon-100 bg-white p-4 md:flex-row"
          >
            <img
              src={mediaUrl(part.images?.[0])}
              alt=""
              className="h-40 w-full rounded-xl object-cover md:w-48"
            />
            <div className="flex-1 space-y-2">
              <h3 className="font-bold">{part.name}</h3>
              <p className="text-amber-600 font-semibold">
                {part.price} {part.currency}
              </p>
              <p className="text-sm text-carbon-600">
                {part.category?.name} · {part.seller?.name} · {part.seller?.phone}
              </p>
              {rejectId === part._id ? (
                <div className="space-y-2 pt-2">
                  <textarea
                    value={rejectNote}
                    onChange={(e) => setRejectNote(e.target.value)}
                    placeholder="Причина отклонения (обязательно)"
                    className="w-full rounded-xl border border-carbon-100 p-3 text-sm outline-none focus:border-red-400"
                    rows={3}
                  />
                  <div className="flex gap-2">
                    <button
                      type="button"
                      disabled={rejecting}
                      onClick={() => handleReject(part._id)}
                      className="rounded-xl bg-red-600 px-4 py-2 text-sm font-medium text-white"
                    >
                      Подтвердить отклонение
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setRejectId(null)
                        setRejectNote('')
                      }}
                      className="rounded-xl border px-4 py-2 text-sm"
                    >
                      Отмена
                    </button>
                  </div>
                </div>
              ) : (
                <div className="flex gap-2 pt-2">
                  <button
                    type="button"
                    onClick={() => handleApprove(part)}
                    className="inline-flex items-center gap-1 rounded-xl bg-green-600 px-4 py-2 text-sm font-medium text-white hover:bg-green-700"
                  >
                    <Check className="h-4 w-4" />
                    Одобрить
                  </button>
                  <button
                    type="button"
                    onClick={() => setRejectId(part._id)}
                    className="inline-flex items-center gap-1 rounded-xl border border-red-200 px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50"
                  >
                    <X className="h-4 w-4" />
                    Отклонить
                  </button>
                </div>
              )}
            </div>
          </article>
        ))}
      </div>

      {result && result.totalPages > 1 && (
        <div className="flex justify-center gap-2">
          <button
            type="button"
            disabled={page <= 1}
            onClick={() => setPage((p) => p - 1)}
            className="rounded-lg border px-3 py-1 text-sm disabled:opacity-40"
          >
            Назад
          </button>
          <span className="text-sm text-carbon-600">
            {page} / {result.totalPages}
          </span>
          <button
            type="button"
            disabled={!result.hasNextPage}
            onClick={() => setPage((p) => p + 1)}
            className="rounded-lg border px-3 py-1 text-sm disabled:opacity-40"
          >
            Далее
          </button>
        </div>
      )}
    </div>
  )
}
