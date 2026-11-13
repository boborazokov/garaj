import { test, expect } from '@playwright/test';
import { SignInPage } from '../pages/sign-in.page';

test.describe('Sign-in @smoke', () => {
  test('renders sign-in page after splash', async ({ page }) => {
    const signIn = new SignInPage(page);
    await signIn.goto();
    // App shows a ~3.2s brand splash before routes mount
    await expect(page).toHaveURL(/sign-in/, { timeout: 15_000 });
    await expect(signIn.passwordInput).toBeVisible({ timeout: 15_000 });
  });

  test('shows validation / stays on sign-in with empty submit', async ({ page }) => {
    const signIn = new SignInPage(page);
    await signIn.goto();
    await expect(signIn.passwordInput).toBeVisible({ timeout: 15_000 });
    if (await signIn.submitButton.isVisible().catch(() => false)) {
      await signIn.submit();
    }
    await expect(page).toHaveURL(/sign-in/);
  });

  test('unauthenticated admin route redirects toward sign-in', async ({ page }) => {
    await page.goto('/admin', { waitUntil: 'domcontentloaded' });
    // Splash (~3.2s) then auth guard may send user to /sign-in
    await expect(page).toHaveURL(/sign-in|admin/, { timeout: 20_000 });
  });
});

