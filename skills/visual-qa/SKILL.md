---
name: visual-qa
description: Verify UI changes in a real browser with Playwright: before/after screenshots, light/dark themes, layout checks, e2e specs that stay green. Use for any change that affects what the user sees. Tests only, never edits production code.
---

# Visual QA with Playwright

Code review and unit tests do not catch visual regressions. This skill is the procedure for checking them in a real browser. It uses the project's own Playwright setup (`@playwright/test`, its `playwright.config.*`, its existing mocks); it does not need a Playwright MCP server.

## Before you start

1. Read the project's `playwright.config.*` and two existing specs: port, base URL, viewport, how the server starts, how the API is mocked.
2. Check the port is free: `ss -ltnp | grep <port>`. Stop only servers you started yourself.
3. If the project has a CI mode (for example `CI=1` serving the production build), use it: build first, then `CI=1 npx playwright test`. Do not run `next dev` or any dev server at the same time as a build: they share the build folder and break each other.

## Capture

- Temporary capture specs go under the project's e2e folder with a `zz-` prefix and are deleted afterwards (`ls e2e | grep zz` must print nothing).
- Screenshots go to the session scratchpad, never into the repository.
- Fixed viewport (use the project's, e.g. 1920x1080). Wait for fonts and images before shooting: for images, wait until `img.complete && img.naturalWidth > 0`; a missing logo on a capture is often just timing.
- Set the state before page load (`page.addInitScript`: localStorage theme, cookies), not after.
- Mock the API with the project's existing full mocks. Empty mocks crash pages that expect arrays or nested objects, and a crashed page is not a result.

## Look at the pictures

Open every screenshot with the image reader and describe it. A green test proves the assertions passed, not that the screen is right.

- **Before/after**: capture the same screen on the base branch and on the change. The base build comes from a temporary worktree of the base branch, created and removed by Gita; Quinn only builds and captures there. State what differs, and whether each difference is intended.
- **Themes**: light and dark side by side. Look for white blocks, unreadable text, low contrast, invisible logos or icons, borders that vanish.
- **Light must stay identical** when the change only targets dark: text sizes, wrapping, spacing, colors of statuses.
- **Overlays**: dev-server error overlays and indicator bubbles are not product defects, but note them.

## Pitfalls seen in practice

- A utility class may not mean what its name says if the project overrides the scale (for example `text-sm` set to 15px while the old inline style was 14px). A converted style can wrap text or shift layout. Compare computed sizes, not class names.
- A dev server that dies mid-run gives `ERR_CONNECTION_REFUSED` and looks like a flaky test. Prefer the built app in CI mode.
- A second server on the same port makes the next run fail with "already used". Check ports before and after.
- Flash-of-wrong-theme tests: abort the JS chunks, load the page, and assert the state on `domcontentloaded`.

## Reporting

- Verdict PASS or FAIL.
- Per screenshot: file, what you see, defects with severity and the suspected file.
- Spec runs: command, and the result of each of at least 3 consecutive runs for a new or rewritten spec.
- Full suite once at the end, in CI mode: pass count.
- Confirmation that no server or `zz-` file is left behind.
