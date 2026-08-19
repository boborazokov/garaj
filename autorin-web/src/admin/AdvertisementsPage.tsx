import { useRef, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import {
  ADMIN_LIST_ADVERTISEMENTS,
  CREATE_ADVERTISEMENT,
  DELETE_ADVERTISEMENT,
  UPDATE_ADVERTISEMENT,
} from '../graphql/operations'
import type { AdvertisementRow, CategoryType, PaginatedAdvertisements } from '../types'
import { mediaUrl } from '../lib/media'
import { uploadAdvertisementBanner } from '../lib/upload'
import { Pagination } from './components/Pagination'
import { Plus, Pencil, Trash2, ExternalLink, Upload, Loader2 } from 'lucide-react'

/** Maps backend `CategoryTypeEnum` → human screen labels in the mobile app. */
const PLACEMENTS: {
  type: CategoryType
  label: string
  hint: string
}[] = [
  { type: 'BRAND', label: 'Главная', hint: 'Home — карусель под промо-блоком' },
  { type: 'PART', label: 'Товары', hint: 'Списки, поиск, деталь товара' },
  { type: 'SERVICE', label: 'Сервисы', hint: 'Список сервисов и деталь мастерской' },
  { type: 'MODEL', label: 'Магазины', hint: 'Профиль продавца (Store)' },
  { type: 'TUNING', label: 'Каталог', hint: 'Категории и inline-баннеры в списках' },
  { type: 'ANNOUNCEMENT', label: 'Заявки', hint: 'Список buy-requests / объявлений' },
]

type FormState = {
  title: string
  bannerImageUrl: string
  link: string
}

const emptyForm = (): FormState => ({ title: '', bannerImageUrl: '', link: '' })

function graphqlErrorMessage(err: unknown): string {
  if (err && typeof err === 'object' && 'graphQLErrors' in err) {
    const gql = err as {
      graphQLErrors?: { message?: string; extensions?: { debug?: string } }[]
      message?: string
    }
    const first = gql.graphQLErrors?.[0]
    const debug = first?.extensions?.debug
    if (typeof debug === 'string' && debug.trim()) return debug
    if (first?.message && first.message !== 'VALIDATION_FAILED') return first.message
  }
  return err instanceof Error ? err.message : 'Ошибка сохранения'
}

function isValidBannerLink(link: string): boolean {
  const v = link.trim()
  if (!v) return false
  if (v.startsWith('/')) return true
  try {
    const parsed = new URL(v.includes('://') ? v : `https://${v}`)
    return (
      parsed.protocol === 'https:' ||
      parsed.protocol === 'http:' ||
      parsed.protocol === 'autorin:'
    )
  } catch {
    return false
  }
}

export function AdminAdvertisementsPage() {
  const [type, setType] = useState<CategoryType>('BRAND')
  const [page, setPage] = useState(1)
  const [editing, setEditing] = useState<AdvertisementRow | null>(null)
  const [creating, setCreating] = useState(false)
  const [form, setForm] = useState<FormState>(emptyForm)
  const [error, setError] = useState<string | null>(null)
  const [uploading, setUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement | null>(null)

  const { data, loading, refetch } = useQuery<{
    adminListAdvertisements: PaginatedAdvertisements
  }>(ADMIN_LIST_ADVERTISEMENTS, {
    variables: { pagination: { page, limit: 12 }, filter: { type } },
  })

  const [createAd] = useMutation(CREATE_ADVERTISEMENT)
  const [updateAd] = useMutation(UPDATE_ADVERTISEMENT)
  const [deleteAd] = useMutation(DELETE_ADVERTISEMENT)

  const result = data?.adminListAdvertisements
  const modalOpen = creating || editing !== null

  function openCreate() {
    setCreating(true)
    setEditing(null)
    setForm(emptyForm())
    setError(null)
  }

  function openEdit(row: AdvertisementRow) {
    setEditing(row)
    setCreating(false)
    setForm({
      title: row.title,
      bannerImageUrl: row.bannerImageUrl,
      link: row.link,
    })
    setError(null)
  }

  function closeModal() {
    setCreating(false)
    setEditing(null)
    setError(null)
  }

  async function save() {
    setError(null)
    if (!form.title.trim() || !form.bannerImageUrl.trim() || !form.link.trim()) {
      setError('Заполните все поля')
      return
    }
    if (!isValidBannerLink(form.link)) {
      setError('Ссылка должна быть https://…, autorin://… или /маршрут в приложении')
      return
    }

    const dataPayload = {
      type,
      title: form.title.trim(),
      bannerImageUrl: form.bannerImageUrl.trim(),
      link: form.link.trim(),
    }

    try {
      if (editing) {
        await updateAd({
          variables: { advertisementId: editing._id, data: dataPayload },
        })
      } else {
        await createAd({ variables: { data: dataPayload } })
      }
      closeModal()
      refetch()
    } catch (e) {
      setError(graphqlErrorMessage(e))
    }
  }

  async function remove(row: AdvertisementRow) {
    if (!confirm(`Удалить баннер «${row.title}»?`)) return
    try {
      await deleteAd({ variables: { advertisementId: row._id } })
      refetch()
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Не удалось удалить')
    }
  }

  async function handleFile(file: File | null | undefined) {
    if (!file) return
    setError(null)
    setUploading(true)
    try {
      const url = await uploadAdvertisementBanner(file)
      setForm((f) => ({ ...f, bannerImageUrl: url }))
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Не удалось загрузить файл')
    } finally {
      setUploading(false)
      if (fileInputRef.current) fileInputRef.current.value = ''
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Реклама / баннеры</h1>
          <p className="text-sm text-carbon-100">
            Загрузите баннер — он автоматически появится в нужном экране приложения.
          </p>
        </div>
        <button
          type="button"
          onClick={openCreate}
          className="inline-flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white"
        >
          <Plus className="h-4 w-4" />
          Добавить баннер
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {PLACEMENTS.map(({ type: t, label, hint }) => (
          <button
            key={t}
            type="button"
            title={hint}
            onClick={() => {
              setType(t)
              setPage(1)
            }}
            className={`rounded-xl px-3 py-1.5 text-sm font-medium ${
              type === t
                ? 'bg-amber-500 text-white'
                : 'bg-carbon-800 text-carbon-100 hover:bg-carbon-700'
            }`}
          >
            {label}
            <span className="ml-1 text-[10px] opacity-60">({t})</span>
          </button>
        ))}
      </div>
      <p className="text-xs text-carbon-300">
        {PLACEMENTS.find((p) => p.type === type)?.hint}
      </p>

      {loading && <p className="text-carbon-100">Загрузка...</p>}

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
        {result?.payload.map((row) => (
          <article
            key={row._id}
            className="overflow-hidden rounded-2xl border border-carbon-600 bg-carbon-800"
          >
            <img
              src={mediaUrl(row.bannerImageUrl)}
              alt=""
              className="h-32 w-full object-cover"
            />
            <div className="space-y-2 p-4">
              <h3 className="font-bold text-white">{row.title}</h3>
              <a
                href={row.link}
                target="_blank"
                rel="noreferrer"
                className="inline-flex items-center gap-1 text-xs text-amber-400"
              >
                Ссылка <ExternalLink className="h-3 w-3" />
              </a>
              <div className="flex gap-2 pt-2">
                <button
                  type="button"
                  onClick={() => openEdit(row)}
                  className="rounded-lg border border-carbon-600 p-2 text-carbon-100"
                >
                  <Pencil className="h-4 w-4" />
                </button>
                <button
                  type="button"
                  onClick={() => remove(row)}
                  className="rounded-lg border border-carbon-600 p-2 text-red-400"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
            </div>
          </article>
        ))}
      </div>

      {result && (
        <Pagination page={page} totalPages={result.totalPages} onPage={setPage} />
      )}

      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="w-full max-w-lg rounded-2xl border border-carbon-600 bg-carbon-800 p-6">
            <h2 className="text-lg font-bold text-white">
              {editing ? 'Редактировать баннер' : 'Новый баннер'} · {type}
            </h2>
            <div className="mt-4 space-y-3">
              <div className="space-y-2">
                <span className="block text-sm text-carbon-100">Изображение баннера *</span>
                <div className="overflow-hidden rounded-xl border border-dashed border-carbon-600 bg-carbon-900">
                  {form.bannerImageUrl ? (
                    <div className="relative">
                      <img
                        src={mediaUrl(form.bannerImageUrl)}
                        alt=""
                        className="h-40 w-full object-cover"
                      />
                      <button
                        type="button"
                        onClick={() => setForm((f) => ({ ...f, bannerImageUrl: '' }))}
                        className="absolute right-2 top-2 rounded-lg bg-black/60 px-2 py-1 text-xs text-white"
                      >
                        Удалить
                      </button>
                    </div>
                  ) : (
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      disabled={uploading}
                      className="flex h-40 w-full flex-col items-center justify-center gap-2 text-sm text-carbon-100 hover:bg-carbon-800 disabled:opacity-60"
                    >
                      {uploading ? (
                        <Loader2 className="h-6 w-6 animate-spin" />
                      ) : (
                        <Upload className="h-6 w-6" />
                      )}
                      <span>{uploading ? 'Загрузка…' : 'Выберите изображение'}</span>
                      <span className="text-xs text-carbon-300">JPG / PNG / WebP, до 10 МБ</span>
                    </button>
                  )}
                </div>
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={(e) => handleFile(e.target.files?.[0])}
                />
                {form.bannerImageUrl && (
                  <button
                    type="button"
                    onClick={() => fileInputRef.current?.click()}
                    disabled={uploading}
                    className="text-xs text-amber-400 hover:underline"
                  >
                    {uploading ? 'Загрузка…' : 'Заменить изображение'}
                  </button>
                )}
              </div>
              <label className="block text-sm text-carbon-100">
                Заголовок *
                <input
                  value={form.title}
                  onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))}
                  className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                />
              </label>
              <label className="block text-sm text-carbon-100">
                Ссылка *
                <input
                  value={form.link}
                  onChange={(e) => setForm((f) => ({ ...f, link: e.target.value }))}
                  placeholder="https://… или autorin://part/123"
                  className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                />
              </label>
              {error && <p className="text-sm text-red-400">{error}</p>}
            </div>
            <div className="mt-6 flex justify-end gap-2">
              <button
                type="button"
                onClick={closeModal}
                className="rounded-xl border border-carbon-600 px-4 py-2 text-sm text-white"
              >
                Отмена
              </button>
              <button
                type="button"
                onClick={save}
                className="rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white"
              >
                Сохранить
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
