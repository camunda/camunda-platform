import { test, expect } from '@playwright/test';
const playwright = require('playwright');

test('test', async ({ page }) => {
  test.setTimeout(60000);
  await page.goto('http://localhost:8082/');
  await page.getByRole('heading', { name: 'Log in' }).waitFor();
  await page.getByLabel('Username or email').click();
  await page.getByLabel('Username or email').fill('demo');
  await page.getByLabel('Password').click();
  await page.getByLabel('Password').fill('demo');
  await page.getByRole('button', { name: 'Log in' }).click();
  await page.getByRole('listitem').filter({ hasText: 'Expand to show filters' }).getByRole('button').click();
  await page.getByRole('link', { name: 'Assigned to me' }).click();
});
