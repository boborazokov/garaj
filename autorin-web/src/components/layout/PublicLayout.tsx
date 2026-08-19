import { Link, NavLink, Outlet } from 'react-router-dom'
import { Search, User, Shield, ClipboardCheck } from 'lucide-react'
import { getUser, isAdmin, isModerator } from '../../lib/auth'

export function PublicLayout() {
  const user = getUser()

  return (
    <div className="flex min-h-screen flex-col">
      <header className="sticky top-0 z-40 border-b border-carbon-100 bg-white/90 backdrop-blur">
        <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-3 md:px-6">
          <Link to="/" className="flex items-center gap-2">
            <span className="flex h-9 w-9 items-center justify-center rounded-xl bg-amber-500 text-sm font-black text-white">
              AR
            </span>
            <span className="text-lg font-bold tracking-tight">AutoRin</span>
          </Link>

          <nav className="hidden items-center gap-6 md:flex">
            <NavLink to="/" className={navClass} end>
              Каталог
            </NavLink>
            <NavLink to="/search" className={navClass}>
              Поиск
            </NavLink>
          </nav>

          <div className="flex items-center gap-2">
            <Link
              to="/search"
              className="rounded-xl p-2 text-carbon-600 hover:bg-carbon-50 md:hidden"
              aria-label="Поиск"
            >
              <Search className="h-5 w-5" />
            </Link>
            {isModerator(user) && (
              <Link
                to="/moderator"
                className="hidden items-center gap-1 rounded-xl border border-carbon-100 px-3 py-2 text-sm font-medium hover:bg-carbon-50 sm:flex"
              >
                <ClipboardCheck className="h-4 w-4" />
                Модерация
              </Link>
            )}
            {isAdmin(user) && (
              <Link
                to="/admin"
                className="hidden items-center gap-1 rounded-xl bg-carbon-900 px-3 py-2 text-sm font-medium text-white hover:bg-carbon-800 sm:flex"
              >
                <Shield className="h-4 w-4" />
                Админ
              </Link>
            )}
            <Link
              to={user ? '/profile' : '/signin'}
              className="flex items-center gap-2 rounded-xl bg-amber-500 px-3 py-2 text-sm font-semibold text-white hover:bg-amber-600"
            >
              <User className="h-4 w-4" />
              {user ? user.name.split(' ')[0] : 'Войти'}
            </Link>
          </div>
        </div>
      </header>

      <main className="mx-auto w-full max-w-7xl flex-1 px-4 py-6 md:px-6 md:py-8">
        <Outlet />
      </main>

      <footer className="border-t border-carbon-100 bg-white py-8 text-center text-sm text-carbon-600">
        © {new Date().getFullYear()} AutoRin — маркетплейс автозапчастей
      </footer>
    </div>
  )
}

function navClass({ isActive }: { isActive: boolean }) {
  return `text-sm font-medium ${isActive ? 'text-amber-600' : 'text-carbon-600 hover:text-carbon-900'}`
}
