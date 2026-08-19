import { useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { BadgeCheck, ShieldAlert } from 'lucide-react'
import {
  ADMIN_LIST_USERS,
  ADMIN_SET_USER_ROLE,
  ADMIN_SET_USER_VERIFIED,
} from '../graphql/operations'
import type { PaginatedUsers, UserRow } from '../types'

const ROLES = ['USER', 'MODERATOR', 'ADMIN'] as const

export function AdminUsersPage() {
  const [search, setSearch] = useState('')
  const [page, setPage] = useState(1)
  // Local optimistic overrides keyed by userId — they vanish once the
  // refetch arrives with the canonical state.
  const [pendingVerified, setPendingVerified] = useState<Record<string, boolean>>(
    {},
  )

  const { data, loading, refetch } = useQuery<{ adminListUsers: PaginatedUsers }>(
    ADMIN_LIST_USERS,
    { variables: { pagination: { page, limit: 20 }, search: search || undefined } },
  )

  const [setRole] = useMutation(ADMIN_SET_USER_ROLE)
  const [setVerified, { loading: verifying }] = useMutation<{
    adminSetUserVerified: { _id: string; verified?: boolean | null }
  }>(ADMIN_SET_USER_VERIFIED)

  const result = data?.adminListUsers

  async function changeRole(user: UserRow, role: string) {
    await setRole({ variables: { userId: user._id, role } })
    refetch()
  }

  async function toggleVerified(user: UserRow) {
    const isVerifiedNow = pendingVerified[user._id] ?? user.verified === true
    const next = !isVerifiedNow
    const confirmText = next
      ? `Верифицировать пользователя «${user.name || user.phone}»?`
      : `Снять верификацию у пользователя «${user.name || user.phone}»?`
    if (!window.confirm(confirmText)) return
    setPendingVerified((p) => ({ ...p, [user._id]: next }))
    try {
      await setVerified({ variables: { userId: user._id, verified: next } })
      await refetch()
      setPendingVerified((p) => {
        const { [user._id]: _drop, ...rest } = p
        return rest
      })
    } catch {
      setPendingVerified((p) => {
        const { [user._id]: _drop, ...rest } = p
        return rest
      })
      window.alert('Не удалось обновить статус верификации.')
    }
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold text-white">Пользователи</h1>
      <input
        value={search}
        onChange={(e) => {
          setSearch(e.target.value)
          setPage(1)
        }}
        onKeyDown={(e) => e.key === 'Enter' && refetch()}
        placeholder="Поиск по имени или телефону"
        className="w-full max-w-md rounded-xl border border-carbon-600 bg-carbon-800 px-4 py-2 text-white outline-none focus:border-amber-500"
      />

      {loading && <p className="text-carbon-100">Загрузка...</p>}

      <div className="overflow-x-auto rounded-2xl border border-carbon-600">
        <table className="w-full min-w-[700px] text-left text-sm">
          <thead className="bg-carbon-800 text-carbon-100">
            <tr>
              <th className="p-3">Имя</th>
              <th className="p-3">Телефон</th>
              <th className="p-3">Роль</th>
              <th className="p-3">Верификация</th>
            </tr>
          </thead>
          <tbody>
            {result?.payload.map((user) => {
              const isVerified =
                pendingVerified[user._id] ?? user.verified === true
              return (
                <tr key={user._id} className="border-t border-carbon-600">
                  <td className="p-3 text-white">
                    <span className="inline-flex items-center gap-1.5">
                      {user.name}
                      {isVerified && (
                        <BadgeCheck
                          className="h-4 w-4 text-sky-400"
                          aria-label="Верифицирован"
                        />
                      )}
                    </span>
                  </td>
                  <td className="p-3 text-carbon-100">{user.phone}</td>
                  <td className="p-3">
                    <select
                      value={user.role}
                      onChange={(e) => changeRole(user, e.target.value)}
                      className="rounded-lg border border-carbon-600 bg-carbon-900 px-2 py-1 text-white"
                    >
                      {ROLES.map((r) => (
                        <option key={r} value={r}>
                          {r}
                        </option>
                      ))}
                    </select>
                  </td>
                  <td className="p-3">
                    <button
                      type="button"
                      disabled={verifying}
                      onClick={() => void toggleVerified(user)}
                      className={`inline-flex items-center gap-1.5 rounded-lg border px-3 py-1.5 text-xs font-semibold transition ${
                        isVerified
                          ? 'border-sky-500/50 bg-sky-500/10 text-sky-300 hover:bg-sky-500/20'
                          : 'border-amber-500/60 bg-amber-500/10 text-amber-300 hover:bg-amber-500/20'
                      } disabled:cursor-not-allowed disabled:opacity-60`}
                    >
                      {isVerified ? (
                        <BadgeCheck className="h-3.5 w-3.5" />
                      ) : (
                        <ShieldAlert className="h-3.5 w-3.5" />
                      )}
                      {isVerified ? 'Снять' : 'Верифицировать'}
                    </button>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {result && result.totalPages > 1 && (
        <div className="flex gap-2">
          <button
            type="button"
            disabled={page <= 1}
            onClick={() => setPage((p) => p - 1)}
            className="rounded-lg bg-carbon-700 px-3 py-1 text-sm disabled:opacity-40"
          >
            Назад
          </button>
          <span className="text-carbon-100">
            {page} / {result.totalPages}
          </span>
          <button
            type="button"
            disabled={!result.hasNextPage}
            onClick={() => setPage((p) => p + 1)}
            className="rounded-lg bg-carbon-700 px-3 py-1 text-sm disabled:opacity-40"
          >
            Далее
          </button>
        </div>
      )}
    </div>
  )
}
