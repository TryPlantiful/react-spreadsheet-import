import { expect, test } from "@playwright/test"

test("selects a spreadsheet header row", async ({ page }) => {
  await page.goto("/iframe.html?id=select-header-step--basic&viewMode=story")

  const row = page.getByRole("row").filter({ hasText: "second" })
  const selector = row.getByRole("radio")
  await expect(selector).not.toBeChecked()
  await row.click()
  await expect(selector).toBeChecked()
})
