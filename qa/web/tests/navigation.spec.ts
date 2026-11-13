import { test, expect } from '@playwright/test';

test.describe('Public navigation @smoke', () => {
  test('root redirects away from bare /', async ({ page }) => {
    await page.goto('/', { waitUntil: 'domcontentloaded' });
    await expect(page).not.toHaveURL(/\/$/, { timeout: 15_000 });
  });

  test('/signup redirects to /sign-in', async ({ page }) => {
    await page.goto('/signup', { waitUntil: 'domcontentloaded' });
    await expect(page).toHaveURL(/sign-in/, { timeout: 15_000 });
  });
});
