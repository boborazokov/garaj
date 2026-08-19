import { useState, type FormEvent } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { useLazyQuery } from '@apollo/client/react'
import { SIGN_IN } from '../graphql/operations'
import { API_URL } from '../lib/config'
import { isAdmin, isModerator, clearSession, setSession, type AuthUser } from '../lib/auth'

function signInErrorMessage(err: unknown): string {
  if (err && typeof err === 'object' && 'graphQLErrors' in err) {
    const gqlErr = err as { graphQLErrors?: { message?: string }[]; message?: string }
    const apiMessage = gqlErr.graphQLErrors?.[0]?.message
    if (apiMessage) return apiMessage
    if (gqlErr.message?.includes('Failed to fetch')) {
      return `Не удалось подключиться к API (${API_URL}). Запустите backend и перезапустите npm run dev.`
    }
  }
  return `Ошибка входа. Проверьте данные и API (${API_URL}).`
}

export function SignInPage() {
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const redirect = params.get('redirect') ?? '/admin'

  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const [signIn, { loading }] = useLazyQuery<
    { signIn: { token: string; user: AuthUser } },
    { data: { phone: string; password: string } }
  >(SIGN_IN, { fetchPolicy: 'network-only' })

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    try {
      const { data } = await signIn({
        variables: { data: { phone: phone.replace(/\D/g, ''), password } },
      })
      if (!data?.signIn) {
        setError('Неверный телефон или пароль')
        return
      }
      setSession(data.signIn.token, data.signIn.user)
      const user = data.signIn.user
      if (isAdmin(user)) {
        navigate(redirect.startsWith('/admin') ? redirect : '/admin')
      } else if (isModerator(user)) {
        navigate(redirect.startsWith('/moderator') ? redirect : '/moderator')
      } else {
        clearSession()
        setError('Доступ только для администраторов и модераторов')
      }
    } catch (err) {
      setError(signInErrorMessage(err))
    }
  }

  return (
    <div>
      <h1 className="mb-2 text-2xl font-bold text-white">Вход в панель</h1>
      <p className="mb-6 text-sm text-carbon-100">AutoRin — администрирование</p>
      <form
        onSubmit={onSubmit}
        className="space-y-4 rounded-2xl border border-carbon-600 bg-carbon-800 p-6"
      >
        <label className="block text-sm font-medium text-carbon-100">
          Телефон
          <input
            type="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="998901234567"
            className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white outline-none focus:border-amber-500"
            required
          />
        </label>
        <label className="block text-sm font-medium text-carbon-100">
          Пароль
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 w-full rounded-xl border border-carbon-600 bg-carbon-900 px-3 py-2 text-white outline-none focus:border-amber-500"
            required
          />
        </label>
        {error && <p className="text-sm text-red-400">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-xl bg-amber-500 py-3 font-semibold text-white hover:bg-amber-600 disabled:opacity-60"
        >
          {loading ? 'Вход...' : 'Войти'}
        </button>
      </form>
    </div>
  )
}
