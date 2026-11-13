import { test, expect } from '@playwright/test';
import { SignInPage } from '../pages/sign-in.page';

test.describe('Network failure handling', () => {
  test('sign-in survives GraphQL API offline', async ({ page }) => {
    await page.route('**/api**', (route) => route.abort('failed'));
    const signIn = new SignInPage(page);
    await signIn.goto();
    await expect(signIn.passwordInput).toBeVisible({ timeout: 15_000 });
    await signIn.fillCredentials('+998901112233', 'wrong-password');
    if (await signIn.submitButton.isVisible().catch(() => false)) {
      await signIn.submit();
    }
    // Must remain on sign-in; must not white-screen
    await expect(page).toHaveURL(/sign-in/);
    await expect(page.locator('body')).not.toBeEmpty();
  });
});
