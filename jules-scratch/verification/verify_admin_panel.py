import re
from playwright.sync_api import Page, expect, sync_playwright

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    # 1. Navigate to the application URL with a generous timeout.
    page.goto("http://localhost:38753", timeout=90000)

    # 2. Wait for the main heading of the app to be visible.
    # This is a more robust way to ensure the app is loaded.
    admin_panel_heading = page.get_by_role("heading", name="Admin Panel")
    expect(admin_panel_heading).to_be_visible(timeout=60000)

    # 3. Take a screenshot of the initial view (Contestant Manager).
    page.screenshot(path="jules-scratch/verification/01_contestant_manager.png")

    # 4. Click on the "Galas" tab using a precise text locator.
    page.get_by_text("Galas", exact=True).click()

    # 5. Wait for the Gala Manager view to be visible and take a screenshot.
    expect(page.get_by_role("heading", name="Manage Galas")).to_be_visible()
    page.screenshot(path="jules-scratch/verification/02_gala_manager.png")

    # 6. Go back to the contestants tab and fill the form.
    page.get_by_text("Contestants", exact=True).click()
    expect(page.get_by_role("heading", name="Manage Contestants")).to_be_visible()

    page.get_by_label("Contestant ID (e.g., contestant_01)").fill("contestant_test_01")
    page.get_by_label("Name").fill("Test Contestant")
    page.get_by_label("Photo URL").fill("http://example.com/photo.jpg")

    page.screenshot(path="jules-scratch/verification/03_contestant_form_filled.png")

    # Clean up
    context.close()
    browser.close()

with sync_playwright() as playwright:
    run(playwright)