import { Link } from 'react-router-dom'
import { MapPin } from 'lucide-react'
import type { Part } from '../types'
import { mediaUrl } from '../lib/media'

function formatPrice(part: Part) {
  const value = part.price?.toLocaleString('ru-RU') ?? '0'
  return `${value} ${part.currency ?? 'UZS'}`
}

export function ProductCard({ part }: { part: Part }) {
  const image = mediaUrl(part.images?.[0])
  const subtitle = [part.brand?.name, part.carModel?.name].filter(Boolean).join(' · ')

  return (
    <Link
      to={`/product/${part._id}`}
      className="group flex flex-col overflow-hidden rounded-2xl border border-carbon-100 bg-white shadow-sm transition hover:border-amber-500/40 hover:shadow-md"
    >
      <div className="relative aspect-[4/3] bg-carbon-100">
        {image ? (
          <img src={image} alt={part.name} className="h-full w-full object-cover" loading="lazy" />
        ) : (
          <div className="flex h-full items-center justify-center text-sm text-carbon-600">Нет фото</div>
        )}
        {part.isPromoted && (
          <span className="absolute left-2 top-2 rounded-full bg-amber-500 px-2 py-0.5 text-xs font-semibold text-white">
            Топ
          </span>
        )}
      </div>
      <div className="flex flex-1 flex-col gap-1 p-4">
        <p className="line-clamp-2 font-semibold text-carbon-900 group-hover:text-amber-600">{part.name}</p>
        {subtitle && <p className="text-xs text-carbon-600">{subtitle}</p>}
        <p className="mt-1 text-lg font-bold text-amber-600">{formatPrice(part)}</p>
        {part.location && (
          <p className="mt-auto flex items-center gap-1 text-xs text-carbon-600">
            <MapPin className="h-3 w-3 shrink-0" />
            {part.location}
          </p>
        )}
      </div>
    </Link>
  )
}
