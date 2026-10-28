import { Link, Outlet, useNavigate } from 'react-router-dom'
import { useEffect } from 'react'
import { clearSession, getUser, isModerator } from '../../lib/auth'
import { LogOut } from 'lucide-react'

export function ModeratorLayout() {
  const navigate = useNavigate()
  const user = getUser()

  useEffect(() => {
    if (!isModerator(user)) navigate('/sign-in', { replace: true })
  }, [user, navigate])

  if (!isModerator(user)) return null

  return (
    <div className="min-h-screen bg-carbon-50">
      <header className="border-b border-carbon-100 bg-white">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-4">
          <div>
            <Link to="/admin" className="text-sm text-amber-600 hover:underline">
              ← В админку
            </Link>
            <h1 className="text-xl font-bold">Панель модератора</h1>
            <p className="text-sm text-carbon-600">{user?.name}</p>
          </div>
          <button
            type="button"
            onClick={() => {
              clearSession()
              navigate('/sign-in')
            }}
            className="flex items-center gap-2 rounded-xl border border-carbon-100 px-3 py-2 text-sm hover:bg-carbon-50"
          >
            <LogOut className="h-4 w-4" />
            Выйти
          </button>
        </div>
      </header>
      <main className="mx-auto max-w-5xl px-4 py-6">
        <Outlet />
      </main>
    </div>
  )
}
