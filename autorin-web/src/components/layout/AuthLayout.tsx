import { Link, Outlet } from 'react-router-dom'

export function AuthLayout() {
  return (
    <div className="flex min-h-screen flex-col bg-carbon-900 text-carbon-50">
      <header className="border-b border-carbon-600 px-4 py-4 md:px-8">
        <Link to="/admin" className="flex items-center gap-2">
          <span className="rounded-lg bg-amber-500 px-2 py-1 text-xs font-black text-white">AR</span>
          <span className="font-bold">AutoRin Admin</span>
        </Link>
      </header>
      <main className="mx-auto flex w-full max-w-md flex-1 flex-col justify-center px-4 py-8">
        <Outlet />
      </main>
    </div>
  )
}
