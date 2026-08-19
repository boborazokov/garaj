import { Link, useParams } from 'react-router-dom'
import { useQuery } from '@apollo/client/react'
import { GET_PART_BY_ID } from '../graphql/operations'
import type { Part } from '../types'
import { mediaUrl } from '../lib/media'
import { ArrowLeft, MapPin, Phone } from 'lucide-react'

const statusLabel: Record<string, string> = {
  ACTIVE: 'Активен',
  ARCHIVED: 'Архив',
  PENDING_MODERATION: 'На проверке',
  REJECTED: 'Отклонён',
}

export function AdminPartDetailPage() {
  const { id } = useParams<{ id: string }>()
  const { data, loading, error } = useQuery<{ getPartById: Part }>(GET_PART_BY_ID, {
    variables: { partId: id },
    skip: !id,
  })

  const part = data?.getPartById

  if (loading) return <p className="text-carbon-100">Загрузка...</p>
  if (error || !part) {
    return (
      <div className="space-y-4">
        <Link to="/admin/parts" className="inline-flex items-center gap-2 text-amber-400 hover:underline">
          <ArrowLeft className="h-4 w-4" />
          К списку
        </Link>
        <p className="text-red-400">Объявление не найдено или недоступно.</p>
      </div>
    )
  }

  const images = part.images?.length ? part.images : ['']
  const price = `${part.price?.toLocaleString('ru-RU')} ${part.currency}`

  return (
    <div className="space-y-6">
      <Link
        to="/admin/parts"
        className="inline-flex items-center gap-2 text-sm text-amber-400 hover:underline"
      >
        <ArrowLeft className="h-4 w-4" />
        К списку объявлений
      </Link>

      <div className="grid gap-8 lg:grid-cols-2">
        <div className="space-y-3">
          <div className="aspect-square overflow-hidden rounded-2xl bg-carbon-800">
            <img
              src={mediaUrl(images[0])}
              alt={part.name}
              className="h-full w-full object-cover"
            />
          </div>
          {images.length > 1 && (
            <div className="flex gap-2 overflow-x-auto">
              {images.map((img, i) => (
                <img
                  key={i}
                  src={mediaUrl(img)}
                  alt=""
                  className="h-20 w-20 shrink-0 rounded-lg object-cover"
                />
              ))}
            </div>
          )}
        </div>

        <div className="space-y-4">
          <div className="flex flex-wrap items-center gap-2">
            <span className="rounded-full bg-carbon-700 px-3 py-1 text-xs text-carbon-100">
              {statusLabel[part.status] ?? part.status}
            </span>
            {part.category?.name && (
              <span className="rounded-full bg-carbon-700 px-3 py-1 text-xs text-carbon-100">
                {part.category.name}
              </span>
            )}
          </div>

          <h1 className="text-2xl font-bold text-white md:text-3xl">{part.name}</h1>
          <p className="text-2xl font-bold text-amber-400">{price}</p>

          <div className="flex flex-wrap gap-2 text-sm">
            {part.brand?.name && (
              <span className="rounded-full bg-carbon-800 px-3 py-1 text-carbon-100">
                {part.brand.name}
              </span>
            )}
            {part.carModel?.name && (
              <span className="rounded-full bg-carbon-800 px-3 py-1 text-carbon-100">
                {part.carModel.name}
              </span>
            )}
            {part.isNew && (
              <span className="rounded-full bg-emerald-900/50 px-3 py-1 text-emerald-300">Новое</span>
            )}
          </div>

          {part.location && (
            <p className="flex items-center gap-2 text-carbon-100">
              <MapPin className="h-4 w-4" />
              {part.location}
              {part.region ? ` · ${part.region}` : ''}
            </p>
          )}

          <p className="whitespace-pre-wrap text-carbon-100">{part.description}</p>

          {part.moderationNote && (
            <div className="rounded-2xl border border-red-500/40 bg-red-500/10 p-4">
              <p className="text-sm text-red-300">Примечание модерации</p>
              <p className="text-white">{part.moderationNote}</p>
            </div>
          )}

          {part.seller && (
            <div className="rounded-2xl border border-carbon-600 bg-carbon-800 p-4">
              <p className="text-sm text-carbon-100">Продавец</p>
              <p className="font-semibold text-white">{part.seller.name}</p>
              {part.seller.address && (
                <p className="text-sm text-carbon-100">{part.seller.address}</p>
              )}
              <a
                href={`tel:${part.seller.phone}`}
                className="mt-2 inline-flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2 font-medium text-white hover:bg-amber-600"
              >
                <Phone className="h-4 w-4" />
                {part.seller.phone}
              </a>
            </div>
          )}

          {part.createdAt && (
            <p className="text-xs text-carbon-500">
              Создано: {new Date(part.createdAt).toLocaleString('ru-RU')}
            </p>
          )}
        </div>
      </div>
    </div>
  )
}
