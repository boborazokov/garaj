import { Link, NavLink, Outlet, useNavigate } from 'react-router-dom'

import {

  LayoutDashboard,

  Users,

  Package,

  Settings,

  LogOut,

  FolderTree,

  Image,

  ShieldCheck,

  ClipboardList,

  MessageSquare,

} from 'lucide-react'

import { useQuery } from '@apollo/client/react'

import { CHAT_GET_CONVERSATIONS } from '../../graphql/operations'

import type { PaginatedConversations } from '../../types'

import { clearSession, getUser, isAdmin } from '../../lib/auth'

import { useEffect } from 'react'



const links = [

  { to: '/admin', label: 'Обзор', icon: LayoutDashboard, end: true },

  { to: '/admin/categories', label: 'Каталог', icon: FolderTree },

  { to: '/admin/advertisements', label: 'Баннеры', icon: Image },

  { to: '/admin/moderation', label: 'Модерация', icon: ShieldCheck },

  { to: '/admin/orders', label: 'Заявки', icon: ClipboardList },

  { to: '/admin/messages', label: 'Сообщения', icon: MessageSquare, badgeKey: 'messages' as const },

  { to: '/admin/users', label: 'Пользователи', icon: Users },

  { to: '/admin/parts', label: 'Объявления', icon: Package },

  { to: '/admin/settings', label: 'Настройки', icon: Settings },

]



export function AdminLayout() {

  const navigate = useNavigate()

  const user = getUser()



  useEffect(() => {

    if (!isAdmin(user)) navigate('/signin?redirect=/admin', { replace: true })

  }, [user, navigate])



  const unreadQuery = useQuery<{ getConversations: PaginatedConversations }>(

    CHAT_GET_CONVERSATIONS,

    {

      variables: { pagination: { page: 1, limit: 50 } },

      pollInterval: 15_000,

      fetchPolicy: 'cache-and-network',

      skip: !isAdmin(user),

      notifyOnNetworkStatusChange: false,

    },

  )



  const messagesUnread = (unreadQuery.data?.getConversations.payload ?? [])

    .reduce((sum, c) => sum + (c.unread ?? 0), 0)



  const badges: Record<string, number> = {

    messages: messagesUnread,

  }



  if (!isAdmin(user)) return null



  return (

    <div className="flex min-h-screen flex-col bg-carbon-900 text-carbon-50 md:flex-row">

      <aside className="hidden w-64 flex-col border-r border-carbon-600 bg-carbon-800 p-4 md:flex">

        <Link to="/admin" className="mb-8 flex items-center gap-2 px-2">

          <span className="rounded-lg bg-amber-500 px-2 py-1 text-xs font-black text-white">AR</span>

          <span className="font-bold">AutoRin Admin</span>

        </Link>

        <nav className="flex flex-1 flex-col gap-1">

          {links.map(({ to, label, icon: Icon, end, badgeKey }) => {

            const badge = badgeKey ? badges[badgeKey] ?? 0 : 0

            return (

              <NavLink

                key={to}

                to={to}

                end={end}

                className={({ isActive }) =>

                  `flex items-center gap-2 rounded-xl px-3 py-2 text-sm ${

                    isActive ? 'bg-amber-500 text-white' : 'text-carbon-100 hover:bg-carbon-700'

                  }`

                }

              >

                <Icon className="h-4 w-4 shrink-0" />

                <span className="flex-1">{label}</span>

                {badge > 0 && (

                  <span className="rounded-full bg-amber-500 px-2 py-0.5 text-[10px] font-bold text-white">

                    {badge > 99 ? '99+' : badge}

                  </span>

                )}

              </NavLink>

            )

          })}

        </nav>

        <button

          type="button"

          onClick={() => {

            clearSession()

            navigate('/signin')

          }}

          className="flex items-center gap-2 rounded-xl px-3 py-2 text-sm text-carbon-100 hover:bg-carbon-700"

        >

          <LogOut className="h-4 w-4" />

          Выйти

        </button>

      </aside>



      <nav className="flex gap-1 overflow-x-auto border-b border-carbon-600 bg-carbon-800 p-2 md:hidden">

        {links.map(({ to, label, end, badgeKey }) => {

          const badge = badgeKey ? badges[badgeKey] ?? 0 : 0

          return (

            <NavLink

              key={to}

              to={to}

              end={end}

              className={({ isActive }) =>

                `shrink-0 rounded-lg px-3 py-2 text-xs font-medium ${

                  isActive ? 'bg-amber-500 text-white' : 'text-carbon-100'

                }`

              }

            >

              <span className="inline-flex items-center gap-1">

                {label}

                {badge > 0 && (

                  <span className="rounded-full bg-white/90 px-1.5 py-0.5 text-[9px] font-bold text-amber-500">

                    {badge > 99 ? '99+' : badge}

                  </span>

                )}

              </span>

            </NavLink>

          )

        })}

      </nav>



      <div className="flex flex-1 flex-col">

        <header className="border-b border-carbon-600 px-4 py-3 md:px-8">

          <p className="text-sm text-carbon-100">Главный администратор</p>

          <p className="font-semibold">{user?.name}</p>

        </header>

        <main className="flex-1 overflow-auto p-4 md:p-8">

          <Outlet />

        </main>

      </div>

    </div>

  )

}


