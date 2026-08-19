import { useEffect, useMemo, useRef, useState } from 'react'
import { useMutation, useQuery } from '@apollo/client/react'
import {
  CREATE_CATEGORY,
  DELETE_CATEGORY,
  GET_CATEGORIES,
  UPDATE_CATEGORY,
} from '../graphql/operations'
import type { CategoryNames, CategoryRow, CategoryType } from '../types'
import {
  categoryLabel,
  emptyCategoryNames,
  namesFromRow,
} from '../lib/category-names'
import { mediaUrl } from '../lib/media'
import { uploadCategoryIcon } from '../lib/upload'
import { Plus, Pencil, Trash2, Upload } from 'lucide-react'

const TYPES: CategoryType[] = [
  'BRAND',
  'MODEL',
  'PART',
  'SERVICE',
  'TUNING',
  'ANNOUNCEMENT',
]

const TYPE_LABELS: Record<CategoryType, string> = {
  BRAND: 'Марки',
  MODEL: 'Модели',
  PART: 'Запчасти',
  SERVICE: 'Услуги',
  TUNING: 'Тюнинг',
  ANNOUNCEMENT: 'Объявления',
}

type FormState = {
  names: CategoryNames
  parentId: string
}

const emptyForm = (): FormState => ({ names: emptyCategoryNames(), parentId: '' })

export function AdminCategoriesPage() {
  const [type, setType] = useState<CategoryType>('BRAND')
  const [search, setSearch] = useState('')
  const [editing, setEditing] = useState<CategoryRow | null>(null)
  const [creating, setCreating] = useState(false)
  const [form, setForm] = useState<FormState>(emptyForm)
  const [iconFile, setIconFile] = useState<File | null>(null)
  const [iconPreview, setIconPreview] = useState<string | null>(null)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const parentType = type === 'MODEL' ? 'BRAND' : type === 'PART' ? 'MODEL' : null

  const { data, loading, refetch } = useQuery<{ getCategories: CategoryRow[] }>(
    GET_CATEGORIES,
    {
      variables: {
        filter: {
          type,
          ...(search.trim() ? { search: search.trim() } : {}),
        },
      },
    },
  )

  const { data: parentsData } = useQuery<{ getCategories: CategoryRow[] }>(
    GET_CATEGORIES,
    {
      skip: !parentType,
      variables: { filter: { type: parentType! } },
    },
  )

  const [createCategory] = useMutation(CREATE_CATEGORY)
  const [updateCategory] = useMutation(UPDATE_CATEGORY)
  const [deleteCategory] = useMutation(DELETE_CATEGORY)

  const categories = data?.getCategories ?? []
  const parents = parentsData?.getCategories ?? []

  const modalOpen = creating || editing !== null

  useEffect(() => {
    return () => {
      if (iconPreview?.startsWith('blob:')) {
        URL.revokeObjectURL(iconPreview)
      }
    }
  }, [iconPreview])

  const parentOptions = useMemo(() => {
    if (type === 'PART') {
      return [
        { id: '', label: 'Без привязки к модели' },
        ...parents.map((p) => ({ id: p._id, label: categoryLabel(p) })),
      ]
    }
    return parents.map((p) => ({ id: p._id, label: categoryLabel(p) }))
  }, [parents, type])

  function clearIconPreview() {
    if (iconPreview?.startsWith('blob:')) {
      URL.revokeObjectURL(iconPreview)
    }
    setIconPreview(null)
    setIconFile(null)
    if (fileInputRef.current) fileInputRef.current.value = ''
  }

  function openCreate() {
    setCreating(true)
    setEditing(null)
    setForm(emptyForm())
    clearIconPreview()
    setError(null)
  }

  function openEdit(row: CategoryRow) {
    setEditing(row)
    setCreating(false)
    setForm({
      names: namesFromRow(row),
      parentId: row.parentId ?? '',
    })
    clearIconPreview()
    setIconPreview(row.iconUrl ? mediaUrl(row.iconUrl) : null)
    setError(null)
  }

  function closeModal() {
    setCreating(false)
    setEditing(null)
    setForm(emptyForm())
    clearIconPreview()
    setError(null)
    setUploading(false)
  }

  function onPickIcon(file: File | undefined) {
    if (!file) return
    if (!file.type.startsWith('image/')) {
      setError('Выберите файл изображения')
      return
    }
    clearIconPreview()
    setIconFile(file)
    setIconPreview(URL.createObjectURL(file))
    setError(null)
  }

  async function save() {
    setError(null)
    const { en, ru, uz } = form.names
    if (!en.trim() || !ru.trim() || !uz.trim()) {
      setError('Заполните название на русском, английском и узбекском')
      return
    }
    if (type === 'MODEL' && !form.parentId) {
      setError('Выберите марку')
      return
    }

    const hasIcon = iconFile != null || (editing?.iconUrl?.trim() ?? '').length > 0
    if (!hasIcon) {
      setError('Загрузите иконку категории')
      return
    }

    setUploading(true)
    try {
      let iconUrl = editing?.iconUrl?.trim() || undefined
      if (iconFile) {
        iconUrl = await uploadCategoryIcon(iconFile)
      }

      const dataPayload = {
        names: {
          en: en.trim(),
          ru: ru.trim(),
          uz: uz.trim(),
        },
        type,
        iconUrl,
        parentId: form.parentId || undefined,
      }

      if (editing) {
        await updateCategory({
          variables: { categoryId: editing._id, data: dataPayload },
        })
      } else {
        await createCategory({ variables: { data: dataPayload } })
      }
      closeModal()
      refetch()
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Ошибка сохранения')
    } finally {
      setUploading(false)
    }
  }

  async function remove(row: CategoryRow) {
    if (!confirm(`Удалить «${categoryLabel(row)}»?`)) return
    try {
      await deleteCategory({ variables: { categoryId: row._id } })
      refetch()
    } catch (e) {
      alert(e instanceof Error ? e.message : 'Не удалось удалить')
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Каталог</h1>
          <p className="text-sm text-carbon-100">
            Как в Telegram-боте: марки, модели, категории запчастей и баннеры.
          </p>
        </div>
        <button
          type="button"
          onClick={openCreate}
          className="inline-flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white"
        >
          <Plus className="h-4 w-4" />
          Добавить
        </button>
      </div>

      <div className="flex flex-wrap gap-2">
        {TYPES.map((t) => (
          <button
            key={t}
            type="button"
            onClick={() => setType(t)}
            className={`rounded-xl px-3 py-1.5 text-sm font-medium ${
              type === t
                ? 'bg-amber-500 text-white'
                : 'bg-carbon-800 text-carbon-100 hover:bg-carbon-700'
            }`}
          >
            {TYPE_LABELS[t]}
          </button>
        ))}
      </div>

      <input
        value={search}
        onChange={(e) => setSearch(e.target.value)}
        placeholder="Поиск по названию"
        className="w-full max-w-md rounded-xl border border-carbon-600 bg-carbon-800 px-4 py-2 text-white outline-none focus:border-amber-500"
      />

      {loading && <p className="text-carbon-100">Загрузка...</p>}

      <div className="overflow-x-auto rounded-2xl border border-carbon-600">
        <table className="w-full min-w-[640px] text-left text-sm">
          <thead className="bg-carbon-800 text-carbon-100">
            <tr>
              <th className="p-3">Иконка</th>
              <th className="p-3">RU</th>
              <th className="p-3">EN</th>
              <th className="p-3">UZ</th>
              <th className="p-3">Родитель</th>
              <th className="p-3 w-28" />
            </tr>
          </thead>
          <tbody>
            {categories.map((row) => {
              const parent = row.parentId
                ? parents.find((p) => p._id === row.parentId)
                : undefined
              const parentName = parent ? categoryLabel(parent) : undefined
              return (
                <tr key={row._id} className="border-t border-carbon-600">
                  <td className="p-3">
                    {row.iconUrl?.trim() ? (
                      <img
                        src={mediaUrl(row.iconUrl)}
                        alt=""
                        className="h-10 w-10 rounded-lg object-cover bg-carbon-700"
                      />
                    ) : (
                      <span className="text-carbon-100">—</span>
                    )}
                  </td>
                  <td className="p-3 font-medium text-white">
                    {categoryLabel(row, 'ru')}
                  </td>
                  <td className="p-3 text-carbon-100">
                    {categoryLabel(row, 'en')}
                  </td>
                  <td className="p-3 text-carbon-100">
                    {categoryLabel(row, 'uz')}
                  </td>
                  <td className="p-3 text-carbon-100">{parentName ?? '—'}</td>
                  <td className="p-3">
                    <div className="flex gap-2">
                      <button
                        type="button"
                        onClick={() => openEdit(row)}
                        className="rounded-lg p-2 text-carbon-100 hover:bg-carbon-700"
                      >
                        <Pencil className="h-4 w-4" />
                      </button>
                      <button
                        type="button"
                        onClick={() => remove(row)}
                        className="rounded-lg p-2 text-red-400 hover:bg-carbon-700"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>

      {!loading && categories.length === 0 && (
        <p className="text-center text-carbon-100">Нет категорий в этом разделе</p>
      )}

      {modalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 p-4">
          <div className="max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-2xl border border-carbon-600 bg-carbon-800 p-6">
            <h2 className="text-lg font-bold text-white">
              {editing ? 'Редактировать' : 'Новая категория'} · {TYPE_LABELS[type]}
            </h2>
            <div className="mt-4 space-y-3">
              {parentType && (
                <label className="block text-sm text-carbon-100">
                  Родитель
                  <select
                    value={form.parentId}
                    onChange={(e) => setForm((f) => ({ ...f, parentId: e.target.value }))}
                    className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                  >
                    {parentOptions.map((o) => (
                      <option key={o.id || 'none'} value={o.id}>
                        {o.label}
                      </option>
                    ))}
                  </select>
                </label>
              )}
              <label className="block text-sm text-carbon-100">
                Название (RU) *
                <input
                  value={form.names.ru}
                  onChange={(e) =>
                    setForm((f) => ({
                      ...f,
                      names: { ...f.names, ru: e.target.value },
                    }))
                  }
                  className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                />
              </label>
              <label className="block text-sm text-carbon-100">
                Name (EN) *
                <input
                  value={form.names.en}
                  onChange={(e) =>
                    setForm((f) => ({
                      ...f,
                      names: { ...f.names, en: e.target.value },
                    }))
                  }
                  className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                />
              </label>
              <label className="block text-sm text-carbon-100">
                Nomi (UZ) *
                <input
                  value={form.names.uz}
                  onChange={(e) =>
                    setForm((f) => ({
                      ...f,
                      names: { ...f.names, uz: e.target.value },
                    }))
                  }
                  className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white"
                />
              </label>
              <div className="block text-sm text-carbon-100">
                <span>Иконка *</span>
                <div className="mt-2 flex flex-wrap items-center gap-4">
                  <div className="flex h-20 w-20 items-center justify-center overflow-hidden rounded-xl border border-carbon-600 bg-carbon-900">
                    {iconPreview ? (
                      <img
                        src={iconPreview}
                        alt=""
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <Upload className="h-8 w-8 text-carbon-100" />
                    )}
                  </div>
                  <div className="space-y-2">
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => onPickIcon(e.target.files?.[0])}
                    />
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="rounded-xl border border-carbon-600 bg-carbon-900 px-4 py-2 text-sm text-white hover:border-amber-500"
                    >
                      {iconPreview ? 'Заменить фото' : 'Загрузить фото'}
                    </button>
                    {iconPreview && (
                      <button
                        type="button"
                        onClick={clearIconPreview}
                        className="block text-xs text-red-400 hover:underline"
                      >
                        Убрать фото
                      </button>
                    )}
                  </div>
                </div>
              </div>
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
                disabled={uploading}
                onClick={save}
                className="rounded-xl bg-amber-500 px-4 py-2 text-sm font-semibold text-white disabled:opacity-50"
              >
                {uploading ? 'Загрузка…' : 'Сохранить'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
