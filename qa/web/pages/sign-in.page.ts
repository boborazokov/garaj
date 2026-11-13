import { type Locator, type Page, expect } from '@playwright/test';

/** Page object for /sign-in (admin / moderator). */
export class SignInPage {
  readonly page: Page;
  readonly phoneInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;
  readonly form: Locator;

  constructor(page: Page) {
    this.page = page;
    this.form = page.locator('form').first();
    this.phoneInput = page.getByRole('textbox').first();
    this.passwordInput = page.locator('input[type="password"]').first();
    this.submitButton = page.getByRole('button').filter({ hasText: /sign|kirish|войти|login/i }).first();
  }

  async goto() {
    await this.page.goto('/sign-in', { waitUntil: 'domcontentloaded' });
    await expect(this.page).toHaveURL(/sign-in/);
  }

  async fillCredentials(phone: string, password: string) {
    await this.phoneInput.fill(phone);
    await this.passwordInput.fill(password);
  }

  async submit() {
    await this.submitButton.click();
  }
}
