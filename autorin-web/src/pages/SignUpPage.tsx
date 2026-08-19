import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { useMutation } from '@apollo/client/react'
import { SIGN_UP } from '../graphql/operations'

export function SignUpPage() {
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')

  const [signUp, { loading }] = useMutation<
    { signUp: { token: string; correctCode: string } },
    { data: { name: string; phone: string; password: string } }
  >(SIGN_UP)

  async function onSubmit(e: FormEvent) {
    e.preventDefault()
    setError('')
    try {
      const { data } = await signUp({
        variables: {
          data: {
            name,
            phone: phone.replace(/\D/g, ''),
            password,
          },
        },
      })
      if (!data?.signUp) return
      sessionStorage.setItem('signup_token', data.signUp.token)
      sessionStorage.setItem('signup_code_hint', data.signUp.correctCode)
      navigate('/confirm')
    } catch {
      setError('Не удалось зарегистрироваться')
    }
  }

  return (
    <div className="mx-auto max-w-md">
      <h1 className="mb-6 text-2xl font-bold">Регистрация</h1>
      <form onSubmit={onSubmit} className="space-y-4 rounded-2xl border border-carbon-100 bg-white p-6">
        <label className="block text-sm font-medium">
          Имя
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            className="mt-1 w-full rounded-xl border border-carbon-100 px-3 py-2 outline-none focus:border-amber-500"
            required
          />
        </label>
        <label className="block text-sm font-medium">
          Телефон
          <input
            type="tel"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="998901234567"
            className="mt-1 w-full rounded-xl border border-carbon-100 px-3 py-2 outline-none focus:border-amber-500"
            required
          />
        </label>
        <label className="block text-sm font-medium">
          Пароль
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="mt-1 w-full rounded-xl border border-carbon-100 px-3 py-2 outline-none focus:border-amber-500"
            required
          />
        </label>
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-xl bg-amber-500 py-3 font-semibold text-white hover:bg-amber-600"
        >
          Продолжить
        </button>
      </form>
      <p className="mt-4 text-center text-sm">
        <Link to="/signin" className="text-amber-600 hover:underline">
          Уже есть аккаунт
        </Link>
      </p>
    </div>
  )
}
