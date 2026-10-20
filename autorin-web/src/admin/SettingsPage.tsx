import { useEffect, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import { GET_APP_SETTINGS, SET_CONTACT_INFO, SET_MODERATION } from '../graphql/operations'
import type { AppSettings } from '../types'
import { Link } from 'react-router-dom'

export function AdminSettingsPage() {
  const { data, refetch } = useQuery<{ getAppSettings: AppSettings }>(GET_APP_SETTINGS)
  const [setModeration, { loading }] = useMutation(SET_MODERATION)
  const [setContact, { loading: savingContact }] = useMutation(SET_CONTACT_INFO)
  const [email, setEmail] = useState('')
  const [phone, setPhone] = useState('')

  const settings = data?.getAppSettings
  const enabled = settings?.productModerationEnabled ?? false

  useEffect(() => {
    if (!settings) return
    setEmail(settings.supportEmail ?? '')
    setPhone(settings.supportPhone ?? '')
  }, [settings])

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

      <form
        className="rounded-2xl border border-carbon-600 bg-carbon-800 p-6"
        onSubmit={async (event) => {
          event.preventDefault()
          await setContact({
            variables: { supportEmail: email.trim(), supportPhone: phone.trim() },
          })
          refetch()
        }}
      >
        <h2 className="font-semibold text-white">Контакты в приложении</h2>
        <p className="mt-2 text-sm text-carbon-100">
          Эти почта и телефон показываются в профиле, в разделе «Свяжитесь с нами».
        </p>
        <label className="mt-5 block text-sm text-carbon-100">
          Email
          <input
            type="email"
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
          />
        </label>
        <label className="mt-4 block text-sm text-carbon-100">
          Телефон
          <input
            type="tel"
            value={phone}
            onChange={(event) => setPhone(event.target.value)}
            className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
          />
        </label>
        <button
          type="submit"
          disabled={savingContact}
          className="mt-5 rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white disabled:opacity-60"
        >
          {savingContact ? 'Сохранение…' : 'Сохранить контакты'}
        </button>
      </form>
    </div>
  )
}
