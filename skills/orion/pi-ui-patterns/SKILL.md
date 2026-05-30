---
name: pi-ui-patterns
description: Design or implement pi terminal UI behavior. Use when adding transient progress, status indicators, widgets, overlays, selection dialogs, settings lists, custom footer/header/editor, autocomplete, working indicators, or custom tool rendering.
---

# Pi UI Patterns

Use this skill whenever pi's terminal UI should change.

## Required reading before implementation

Read completely:

1. `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\tui.md`
2. `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\extensions.md`

Then inspect relevant examples in:

`C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\examples\extensions`

## Choose the lightest UI mechanism

Prefer simple APIs before custom components:

1. `ctx.ui.notify(...)` for brief notifications.
2. `ctx.ui.setStatus(id, text)` for footer status.
3. `ctx.ui.setWidget(id, ...)` for persistent above/below-editor content.
4. `ctx.ui.setWorkingMessage(...)`, `setWorkingVisible(...)`, or `setWorkingIndicator(...)` for streaming indicators.
5. `ctx.ui.select`, `confirm`, `input`, `editor` for standard prompts.
6. `ctx.ui.custom(...)` only for complex interactive UI.
7. `ctx.ui.setFooter(...)`, `setHeader(...)`, or `setEditorComponent(...)` only when replacing core UI regions is intended.

## Common patterns

### Transient progress

Use a widget/status pair and clear it on `agent_end` or after a timer. Clean timers on `session_shutdown`.

### Persistent mode indicator

Use:

```ts
ctx.ui.setStatus("my-mode", ctx.ui.theme.fg("accent", "mode: on"));
ctx.ui.setStatus("my-mode", undefined);
```

### Above-editor widget

Use:

```ts
ctx.ui.setWidget("my-widget", ["Line 1", "Line 2"], { placement: "aboveEditor" });
ctx.ui.setWidget("my-widget", undefined);
```

### Selection dialog

Use `SelectList` from `@earendil-works/pi-tui` and `DynamicBorder` from `@earendil-works/pi-coding-agent`. Follow the exact pattern in `docs/tui.md`.

### Cancellable async operation

Use `BorderedLoader` from `@earendil-works/pi-coding-agent`.

### Settings/toggles

Use `SettingsList` from `@earendil-works/pi-tui` and `getSettingsListTheme()`.

### Custom editor

Extend `CustomEditor` from `@earendil-works/pi-coding-agent`, not the base editor. Call `super.handleInput(data)` for keys not handled by the custom editor.

## Rendering rules

- Every rendered line must be no wider than the `width` argument.
- Use `truncateToWidth`, `visibleWidth`, and `wrapTextWithAnsi` from `@earendil-works/pi-tui`.
- Always use the `theme` passed into render/custom callbacks; do not import or cache a global theme.
- Call `tui.requestRender()` after state changes inside custom components.
- Implement `invalidate()` on custom components.
- If storing themed strings, rebuild them in `invalidate()`.
- For focusable inputs, implement/proxy the `Focusable` interface so IME cursor placement works.

## UI safety and compatibility

- Check `ctx.hasUI` before using interactive UI in code that may run in print/JSON mode.
- Overlays are experimental; prefer normal `ctx.ui.custom()` unless overlay behavior is explicitly needed.
- Clear widgets/status/footer/editor replacements on shutdown if they are temporary.
- Keep UI concise; avoid flooding the message history for ephemeral state.
- Do not claim to display private reasoning. Only display summaries/progress/status.

## Examples to inspect

- `status-line.ts` — status footer indicator
- `widget-placement.ts` — widgets above/below editor
- `working-indicator.ts` — streaming working indicator
- `custom-footer.ts` — custom footer
- `custom-header.ts` — custom header
- `modal-editor.ts` — custom editor
- `overlay-test.ts` and `overlay-qa-tests.ts` — overlays
- `qna.ts` and `questionnaire.ts` — custom interactive UI
- `todo.ts` — custom tool rendering
- `github-issue-autocomplete.ts` — autocomplete provider

## Reload

After editing a project-local extension or skill, tell the user:

```text
/reload
```
