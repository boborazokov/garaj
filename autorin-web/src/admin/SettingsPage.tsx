import { useMutation, useQuery } from '@apollo/client/react'
import { GET_APP_SETTINGS, SET_MODERATION } from '../graphql/operations'
import type { AppSettings } from '../types'
import { Link } from 'react-router-dom'

export function AdminSettingsPage() {
  const { data, refetch } = useQuery<{ getAppSettings: AppSettings }>(GET_APP_SETTINGS)
  const [setModeration, { loading }] = useMutation(SET_MODERATION)

  const enabled = data?.getAppSettings.productModerationEnabled ?? false

  return (
    <div className="max-w-xl space-y-6">
      <h1 className="text-2xl font-bold text-white">Настройки</h1>

      <div className="rounded-2xl border border-carbon-600 bg-carbon-800 p-6">
        <h2 className="font-semibold text-white">Модерация товаров</h2>
        <p className="mt-2 text-sm text-carbon-100">
          Если включено — новые товары попадают в очередь модератора и не видны в каталоге до
          одобрения. Если выключено — товары публикуются сразу.
        </p>

        <div className="mt-6 flex items-center justify-between gap-4">
          <span className={`font-medium ${enabled ? 'text-amber-400' : 'text-carbon-100'}`}>
            {enabled ? 'Включена' : 'Выключена'}
          </span>
          <button
            type="button"
            disabled={loading}
            onClick={async () => {
              await setModeration({ variables: { enabled: !enabled } })
              refetch()
            }}
            className={`relative h-8 w-14 rounded-full transition ${
              enabled ? 'bg-amber-500' : 'bg-carbon-600'
            }`}
          >
            <span
              className={`absolute top-1 h-6 w-6 rounded-full bg-white transition ${
                enabled ? 'left-7' : 'left-1'
              }`}
            />
          </button>
        </div>

        {enabled && (
          <p className="mt-4 text-sm">
            <Link to="/admin/moderation" className="text-amber-400 hover:underline">
              Открыть очередь модерации →
            </Link>
          </p>
        )}
      </div>
    </div>
  )
}
