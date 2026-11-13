import { defineConfig, devices } from '@playwright/test';
import path from 'node:path';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(__dirname, '.env') });
dotenv.config({ path: path.resolve(__dirname, '../.env') });

const BASE_URL = process.env.QA_WEB_BASE_URL ?? 'http://127.0.0.1:5173';
const isCI = !!process.env.CI;

/**
 * AutoRin web QA — targets autorin-web (Vite :5173).
 * Never point QA_WEB_BASE_URL at production without explicit permission.
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: isCI,
  retries: isCI ? 2 : 1,
  // Evidence from audit: 6 workers + 3.2s splash caused intermittent page.goto(load) timeouts.
  workers: isCI ? 2 : 3,
  timeout: 60_000,
  expect: { timeout: 10_000 },
  reporter: [
    ['list'],
    ['html', { outputFolder: path.resolve(__dirname, '../reports/playwright-html'), open: 'never' }],
    ['json', { outputFile: path.resolve(__dirname, '../reports/playwright-results.json') }],
  ],
  outputDir: path.resolve(__dirname, '../screenshots/playwright-artifacts'),
  use: {
    baseURL: BASE_URL,
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 15_000,
    // Prefer DOM readiness over full window load (Vite HMR / long-lived assets).
    navigationTimeout: 45_000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    {
      name: 'mobile-chrome',
      use: { ...devices['Pixel 7'] },
    },
    {
      name: 'mobile-safari',
      use: { ...devices['iPhone 14'] },
    },
  ],
  /* Start Vite only when explicitly enabled (avoids surprise process spawn). */
  webServer: process.env.QA_START_WEB === '1'
    ? {
        command: 'npm run dev --prefix ../../autorin-web',
        url: BASE_URL,
        reuseExistingServer: !isCI,
        timeout: 120_000,
      }
    : undefined,
});
