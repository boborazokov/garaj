interface PaginationProps {
  page: number
  totalPages: number
  onPage: (page: number) => void
}

export function Pagination({ page, totalPages, onPage }: PaginationProps) {
  if (totalPages <= 1) return null

  return (
    <div className="flex gap-2">
      <button
        type="button"
        disabled={page <= 1}
        onClick={() => onPage(page - 1)}
        className="rounded-lg border border-carbon-600 px-3 py-1 text-sm text-white disabled:opacity-40"
      >
        Назад
      </button>
      <span className="self-center text-sm text-carbon-100">
        {page} / {totalPages}
      </span>
      <button
        type="button"
        disabled={page >= totalPages}
        onClick={() => onPage(page + 1)}
        className="rounded-lg border border-carbon-600 px-3 py-1 text-sm text-white disabled:opacity-40"
      >
        Далее
      </button>
    </div>
  )
}
