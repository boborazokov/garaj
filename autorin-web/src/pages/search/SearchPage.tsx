import { useState } from 'react'
import { useQuery } from '@apollo/client/react'
import { GET_PARTS } from '../../graphql/operations'
import { ProductCard } from '../../components/ProductCard'
import type { PaginatedParts } from '../../types'
import { Search } from 'lucide-react'

export function SearchPage() {
  const [query, setQuery] = useState('')
  const [submitted, setSubmitted] = useState('')

  const { data, loading } = useQuery<{ getParts: PaginatedParts }>(GET_PARTS, {
    variables: {
      pagination: { page: 1, limit: 24 },
      search: submitted || undefined,
      sort: 'NEWEST',
    },
    skip: !submitted,
  })

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Поиск</h1>
      <form
        className="flex gap-2"
        onSubmit={(e) => {
          e.preventDefault()
          setSubmitted(query.trim())
        }}
      >
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-carbon-600" />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Название запчасти..."
            className="w-full rounded-xl border border-carbon-100 bg-white py-3 pl-10 pr-4 outline-none focus:border-amber-500"
          />
        </div>
        <button
          type="submit"
          className="rounded-xl bg-amber-500 px-6 font-semibold text-white hover:bg-amber-600"
        >
          Искать
        </button>
      </form>

      {!submitted && <p className="text-carbon-600">Введите запрос и нажмите «Искать».</p>}

      {loading && <p>Загрузка...</p>}

      {data?.getParts && (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {data.getParts.payload.map((part) => (
            <ProductCard key={part._id} part={part} />
          ))}
        </div>
      )}

      {submitted && data?.getParts.payload.length === 0 && !loading && (
        <p className="text-carbon-600">Ничего не найдено.</p>
      )}
    </div>
  )
}
