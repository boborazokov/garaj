import { useParams, Link } from 'react-router-dom'
import { useQuery } from '@apollo/client/react'
import { GET_PART_BY_ID } from '../../graphql/operations'
import type { Part } from '../../types'
import { mediaUrl } from '../../lib/media'
import { Phone, MapPin } from 'lucide-react'

export function ProductPage() {
  const { id } = useParams<{ id: string }>()
  const { data, loading, error } = useQuery<{ getPartById: Part }>(GET_PART_BY_ID, {
    variables: { partId: id },
    skip: !id,
  })

  const part = data?.getPartById

  if (loading) return <p>Загрузка...</p>
  if (error || !part) {
    return (
      <p className="text-red-600">
        Товар не найден или недоступен.
        <Link to="/" className="ml-2 text-amber-600 underline">
          На главную
        </Link>
      </p>
    )
  }

  const images = part.images?.length ? part.images : ['']
  const price = `${part.price?.toLocaleString('ru-RU')} ${part.currency}`

  return (
    <div className="grid gap-8 lg:grid-cols-2">
      <div className="space-y-3">
        <div className="aspect-square overflow-hidden rounded-2xl bg-carbon-100">
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
        <h1 className="text-2xl font-bold md:text-3xl">{part.name}</h1>
        <p className="text-2xl font-bold text-amber-600">{price}</p>

        <div className="flex flex-wrap gap-2 text-sm">
          {part.brand?.name && (
            <span className="rounded-full bg-carbon-100 px-3 py-1">{part.brand.name}</span>
          )}
          {part.carModel?.name && (
            <span className="rounded-full bg-carbon-100 px-3 py-1">{part.carModel.name}</span>
          )}
          {part.isNew && (
            <span className="rounded-full bg-green-100 px-3 py-1 text-green-800">Новое</span>
          )}
        </div>

        {part.location && (
          <p className="flex items-center gap-2 text-carbon-600">
            <MapPin className="h-4 w-4" />
            {part.location}
          </p>
        )}

        <p className="whitespace-pre-wrap text-carbon-600">{part.description}</p>

        {part.seller && (
          <div className="rounded-2xl border border-carbon-100 bg-white p-4">
            <p className="text-sm text-carbon-600">Продавец</p>
            <p className="font-semibold">{part.seller.name}</p>
            <a
              href={`tel:${part.seller.phone}`}
              className="mt-2 inline-flex items-center gap-2 rounded-xl bg-amber-500 px-4 py-2 font-medium text-white hover:bg-amber-600"
            >
              <Phone className="h-4 w-4" />
              {part.seller.phone}
            </a>
          </div>
        )}
      </div>
    </div>
  )
}
