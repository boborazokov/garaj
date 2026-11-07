import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { AdminLayout } from "./components/layout/AdminLayout";
import { ModeratorLayout } from "./components/layout/ModeratorLayout";
import { SignInPage } from "./pages/sign-in";
import { DashboardPage } from "./pages/dashboard";
import { ProductsPage } from "./pages/products";
import { WorkshopsPage } from "./pages/workshops";
import { CategoriesPage } from "./pages/categories";
import { BannersPage } from "./pages/banners";
import { AdminSettingsPage } from "./admin/SettingsPage";
import { MessagesPage } from "./pages/messages";
import { ModerationPage } from "./pages/moderation";
import { UserInfoPage } from "./pages/user-info";
import { UsersPage } from "./pages/users";
import { OrdersPage } from "./pages/orders";

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Navigate to="/admin" replace />} />

        <Route path="/sign-in" element={<SignInPage />} />
        <Route path="/signup" element={<Navigate to="/sign-in" replace />} />

        <Route path="/admin" element={<AdminLayout />}>
          <Route index element={<DashboardPage />} />
          <Route path="categories" element={<CategoriesPage />} />
          <Route path="advertisements" element={<BannersPage />} />

          <Route path="moderation" element={<ModerationPage />} />
          <Route path="orders" element={<OrdersPage />} />
          <Route path="messages" element={<MessagesPage />} />
          <Route path="users" element={<UsersPage />} />
          <Route path="users/:userId" element={<UserInfoPage />} />
          <Route path="products" element={<ProductsPage />} />
          <Route path="products/:id" element={<Navigate to="/admin/products" replace />} />
          <Route path="parts" element={<Navigate to="/admin/products" replace />} />
          <Route path="parts/:id" element={<Navigate to="/admin/products" replace />} />
          <Route path="workshops" element={<WorkshopsPage />} />
          <Route path="settings" element={<AdminSettingsPage />} />
        </Route>

        <Route path="/moderator" element={<ModeratorLayout />}>
          <Route index element={<ModerationPage />} />
        </Route>

        <Route path="*" element={<Navigate to="/admin" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
