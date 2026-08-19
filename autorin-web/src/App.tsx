import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom'
import { AuthLayout } from './components/layout/AuthLayout'
import { AdminLayout } from './components/layout/AdminLayout'
import { ModeratorLayout } from './components/layout/ModeratorLayout'
import { SignInPage } from './pages/SignInPage'
import { AdminDashboardPage } from './admin/DashboardPage'
import { AdminUsersPage } from './admin/UsersPage'
import { AdminPartsPage } from './admin/PartsPage'
import { AdminPartDetailPage } from './admin/PartDetailPage'
import { AdminSettingsPage } from './admin/SettingsPage'
import { AdminCategoriesPage } from './admin/CategoriesPage'
import { AdminAdvertisementsPage } from './admin/AdvertisementsPage'
import { AdminMessagesPage } from './admin/MessagesPage'
import { AdminModerationPage } from './admin/ModerationPage'
import { AdminOrdersPage } from './admin/OrdersPage'
import { ModeratorQueuePage } from './moderator/QueuePage'

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin" replace />} />

        <Route element={<AuthLayout />}>
          <Route path="signin" element={<SignInPage />} />
        </Route>

        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<AdminDashboardPage />} />
          <Route path="categories" element={<AdminCategoriesPage />} />
          <Route path="advertisements" element={<AdminAdvertisementsPage />} />
          <Route path="moderation" element={<AdminModerationPage />} />
          <Route path="orders" element={<AdminOrdersPage />} />
          <Route path="messages" element={<AdminMessagesPage />} />
          <Route path="users" element={<AdminUsersPage />} />
          <Route path="parts" element={<AdminPartsPage />} />
          <Route path="parts/:id" element={<AdminPartDetailPage />} />
          <Route path="settings" element={<AdminSettingsPage />} />
        </Route>

        <Route path="/moderator" element={<ModeratorLayout />}>
          <Route index element={<ModeratorQueuePage />} />
        </Route>

        <Route path="*" element={<Navigate to="/admin" replace />} />
      </Routes>
    </BrowserRouter>
  )
}
