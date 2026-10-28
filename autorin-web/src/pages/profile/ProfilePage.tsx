import { Link, useNavigate } from 'react-router-dom'
import { clearSession, getUser, isAdmin, isModerator } from '../../lib/auth'

export function ProfilePage() {
  const user = getUser()
  const navigate = useNavigate()

  if (!user) {
    return (
      <p>
        <Link to="/sign-in" className="text-amber-600 underline">
          Войдите
        </Link>{' '}
        в аккаунт
      </p>
    )
  }

  return (
    <div className="mx-auto max-w-lg space-y-6">
      <h1 className="text-2xl font-bold">Профиль</h1>
      <div className="rounded-2xl border border-carbon-100 bg-white p-6">
        <p className="text-sm text-carbon-600">Имя</p>
        <p className="text-lg font-semibold">{user.name}</p>
        <p className="mt-4 text-sm text-carbon-600">Телефон</p>
        <p className="font-medium">{user.phone}</p>
        <p className="mt-4 text-sm text-carbon-600">Роль</p>
        <p className="font-medium">{user.role}</p>
      </div>
      <div className="flex flex-wrap gap-3">
        {isModerator(user) && (
          <Link
            to="/moderator"
            className="rounded-xl border border-carbon-100 px-4 py-2 font-medium hover:border-amber-500"
          >
            Модерация
          </Link>
        )}
        {isAdmin(user) && (
          <Link
            to="/admin"
            className="rounded-xl bg-carbon-900 px-4 py-2 font-medium text-white"
          >
            Админ-панель
          </Link>
        )}
        <button
          type="button"
          onClick={() => {
            clearSession()
            navigate('/')
          }}
          className="rounded-xl border border-red-200 px-4 py-2 text-red-600"
        >
          Выйти
        </button>
      </div>
    </div>
  )
}
