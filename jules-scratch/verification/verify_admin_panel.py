from playwright.sync_api import sync_playwright

def run(playwright):
    browser = playwright.chromium.launch(headless=True)
    context = browser.new_context()
    page = context.new_page()

    # It's a mobile app, so we can't navigate to a URL.
    # We will assume the app is already running.
    # We will just take a screenshot of the current view.
    page.screenshot(path="jules-scratch/verification/contestant_manager.png")

    # We can't navigate to the gala manager directly, so we will
    # assume the user will navigate to it manually.
    # We will just take another screenshot.
    page.screenshot(path="jules-scratch/verification/gala_manager.png")

    context.close()
    browser.close()

with sync_playwright() as playwright:
    run(playwright)