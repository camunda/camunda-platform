import { test, expect } from '@playwright/test';
const playwright = require('playwright');

test('test', async ({ page }) => {
  test.setTimeout(60000);
  await page.goto('http://localhost:8083/');
  await page.getByRole('heading', { name: 'Log in' }).waitFor();
  await page.getByLabel('Username or email').click();
  await page.getByLabel('Username or email').fill('demo');
  await page.getByLabel('Password').click();
  await page.getByLabel('Password').fill('demo');
  await page.getByRole('button', { name: 'Log in' }).click();
  try {
    await page.getByText('Close').click({timeout: 5000});
  } catch (e) {
    if (e instanceof playwright.errors.TimeoutError) {
      console.log("Popup of release features sometimes appears here. Perhaps you've already closed this out once. ignoring...");
    }
  }
  await page.getByRole('button', { name: 'Create New Dashboard' }).click();
});
