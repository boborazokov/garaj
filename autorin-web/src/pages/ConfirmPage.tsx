import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { useMutation } from '@apollo/client/react'
import { CONFIRM_SIGN_UP } from '../graphql/operations'
import { setSession, type AuthUser } from '../lib/auth'

export function ConfirmPage() {
  const navigate = useNavigate()
  const token = sessionStorage.getItem('signup_token') ?? ''
  const hint = sessionStorage.getItem('signup_code_hint')
  const [code, setCode] = useState('')
  const [error, setError] = useState('')

  const [confirm, { loading }] = useMutation<
    { confirmSignUp: { token: string; refreshToken?: string | null; user: AuthUser } },
    { token: string; code: string }
  >(CONFIRM_SIGN_UP)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    try {
      const { data } = await confirm({ variables: { token, code } })
      if (!data?.confirmSignUp) return
      setSession(data.confirmSignUp.token, data.confirmSignUp.user, data.confirmSignUp.refreshToken)
      sessionStorage.removeItem('signup_token')
      sessionStorage.removeItem('signup_code_hint')
      navigate('/')
    } catch {
      setError('Неверный код')
    }
  }

  if (!token) {
    return <p className="text-red-600">Сначала пройдите регистрацию.</p>
  }

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-2 text-2xl font-bold">Подтверждение</h1>
      <p className="mb-6 text-sm text-carbon-600">Введите код из SMS</p>
      {import.meta.env.DEV && hint && (
        <p className="mb-4 rounded-lg bg-amber-50 p-3 text-sm text-amber-800">
          Dev: код <strong>{hint}</strong>
        </p>
      )}
      <form onSubmit={onSubmit} className="space-y-4 rounded-2xl border border-carbon-100 bg-white p-6">
        <input
          value={code}
          onChange={(e) => setCode(e.target.value)}
          placeholder="Код"
          className="w-full rounded-xl border border-carbon-100 px-3 py-3 text-center text-lg tracking-widest outline-none focus:border-amber-500"
          required
        />
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-xl bg-amber-500 py-3 font-semibold text-white"
        >
          Подтвердить
        </button>
      </form>
    </div>
  )
}
