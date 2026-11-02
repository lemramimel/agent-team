---
name: ui-craft
description: Procedure for designing and building UI that looks intentional and stays consistent with the project: design plan, token discipline, states, themes, accessibility, self-critique. Use for any task that changes what the user sees.
---

# UI craft

Project-agnostic baseline. It works with any front-end stack and with any design system. Companion skills (`frontend-design`, `impeccable`) add taste and review passes on top; this skill is the floor.

## 1. Understand before designing
- Who uses this screen, and what is their main job on it? If the brief does not say, ask once.
- Read the existing UI first: components, tokens, theme setup, spacing and type scales, wording language. Consistency beats novelty.
- List the states the screen needs: empty, loading, error, success, partial, disabled. Sally's UX note defines them; if there is none, define them.

## 2. Design plan (short, before any code)
Write it in a few lines, in the brief or the report:
- Palette: which tokens, and what carries meaning (status, emphasis).
- Type: which scale steps for title, body, caption, data.
- Layout: the structure in words or a rough wireframe, and how it behaves from phone to wide desktop.
- Principles: what this screen should feel like, and which generic defaults you will avoid (default card grids, gradient stats, decoration without information).
Then compare the plan to the brief and drop what is generic. Only then build.

## 3. Build
- Reuse components. Create a new one only when two or more places need it or none fits.
- Tokens only for color, spacing, radius, shadow. A hard-coded color is a bug the day a theme changes.
- Check the project's scale before swapping a fixed size for a utility class: a project may define `text-sm` as 15px where the old style was 14px.
- Motion is rare and purposeful: feedback to an action, or one orchestrated moment. Respect reduced motion.
- Copy speaks to the user, in active voice, with the project's terminology. Errors say what happened and what to do.

## 4. Themes
- If the project has light and dark: both are designed, not derived. Check text on every surface, borders that vanish, logos and icons that disappear, status colors (tint plus a lighter text in dark).
- Light must stay unchanged when a change only targets dark.

## 5. Accessibility floor
- Everything reachable and operable by keyboard, with a visible focus.
- Names for icon buttons, labels for inputs, correct roles for custom widgets.
- Contrast AA for body text, not color alone for meaning.
- Respect `prefers-reduced-motion`.

## 6. Self-critique before handing over
- Does it match the plan and the brief? What looks generic, crowded or inconsistent?
- Every state reachable and designed? Narrow and wide screens checked?
- Hand to Quinn with the list of screens, states and themes to capture. You do not call it done on unit tests alone.

## Companions
`frontend-design` and `impeccable` (see `docs/COMPANIONS.md`): use `impeccable`'s shape, critique and polish passes when installed. Do not stack several style engines; one direction per screen.
