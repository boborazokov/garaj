import { useQuery } from '@apollo/client/react'
import { GET_PARTS } from '../graphql/operations'
import { ProductCard } from '../components/ProductCard'
import type { PaginatedParts } from '../types'
import { Link } from 'react-router-dom'
import { Search } from 'lucide-react'

export function HomePage() {
  const { data, loading, error, fetchMore } = useQuery<{ getParts: PaginatedParts }>(GET_PARTS, {
    variables: {
      pagination: { page: 1, limit: 12 },
      sort: 'RECOMMENDED',
    },
  })

  const result = data?.getParts

  return (
    <div className="space-y-8">
      <section className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-carbon-900 via-carbon-800 to-carbon-900 px-6 py-12 text-white md:px-10 md:py-16">
        <div className="relative z-10 max-w-xl space-y-4">
          <p className="text-sm font-semibold uppercase tracking-wider text-amber-400">AutoRin Web</p>
          <h1 className="text-3xl font-bold leading-tight md:text-4xl">
            Запчасти и объявления для вашего авто
          </h1>
          <p className="text-carbon-100">
            Каталог с проверкой качества. Покупайте и продавайте запчасти удобно с компьютера.
          </p>
          <Link
            to="/search"
            className="inline-flex items-center gap-2 rounded-xl bg-amber-500 px-5 py-3 font-semibold text-white hover:bg-amber-600"
          >
            <Search className="h-4 w-4" />
            Найти запчасть
          </Link>
        </div>
        <div className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-amber-500/20 blur-3xl" />
      </section>

      <section>
        <div className="mb-4 flex items-end justify-between">
          <h2 className="text-xl font-bold">Рекомендуемые товары</h2>
        </div>

        {loading && !result && (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="h-72 animate-pulse rounded-2xl bg-carbon-100" />
            ))}
          </div>
        )}

        {error && (
          <p className="rounded-xl border border-red-200 bg-red-50 p-4 text-red-700">
            Не удалось загрузить каталог. Проверьте API: {error.message}
          </p>
        )}

        {result && (
          <>
            <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
              {result.payload.map((part) => (
                <ProductCard key={part._id} part={part} />
              ))}
            </div>
            {result.hasNextPage && (
              <div className="mt-8 flex justify-center">
                <button
                  type="button"
                  disabled={loading}
                  onClick={() =>
                    fetchMore({
                      variables: {
                        pagination: { page: result.nextPage ?? result.page + 1, limit: 12 },
                      },
                      updateQuery: (prev, { fetchMoreResult }) => {
                        if (!fetchMoreResult) return prev
                        return {
                          getParts: {
                            ...fetchMoreResult.getParts,
                            payload: [
                              ...prev.getParts.payload,
                              ...fetchMoreResult.getParts.payload,
                            ],
                          },
                        }
                      },
                    })
                  }
                  className="rounded-xl border border-carbon-100 bg-white px-6 py-2 font-medium hover:border-amber-500"
                >
                  Загрузить ещё
                </button>
              </div>
            )}
          </>
        )}
      </section>
    </div>
  )
}
