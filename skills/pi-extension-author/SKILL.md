---
name: pi-extension-author
description: Build, modify, debug, or review pi coding agent extensions. Use when adding pi tools, commands, event hooks, providers, autocomplete, custom renderers, permission gates, model/status behavior, or runtime functionality.
---

# Pi Extension Author

Use this skill when the user asks to update pi's runtime behavior with an extension.

## Required reading before implementation

Read these docs completely before editing extension code:

1. `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\extensions.md`
2. For UI, also read `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\tui.md`
3. If packaging for reuse, also read `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\packages.md`

Then inspect relevant examples in:

`C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\examples\extensions`

## Where to put extensions

- Project-local: `.pi/extensions/<name>.ts` or `.pi/extensions/<name>/index.ts`
- Global: `~/.pi/agent/extensions/<name>.ts` or `~/.pi/agent/extensions/<name>/index.ts`

Prefer project-local unless the user explicitly wants global behavior.

## Extension decision checklist

Use an extension, not a skill, when the feature needs any of these:

- Custom tools callable by the model
- Slash commands
- Keyboard shortcuts
- UI widgets, status lines, overlays, custom footer/header/editor
- Event hooks such as `input`, `agent_start`, `tool_call`, `tool_result`, `session_start`
- Provider/model registration
- Permission gates or tool interception
- Session state persistence

## Implementation workflow

1. Clarify the desired user-facing behavior.
2. Choose extension location and filename.
3. Select minimal APIs:
   - `pi.on(...)` for lifecycle/event behavior
   - `pi.registerTool(...)` for model-callable tools
   - `pi.registerCommand(...)` for slash commands
   - `ctx.ui.*` for UI behavior
   - `pi.appendEntry(...)` or tool result `details` for persistent state
4. Copy the closest official example pattern instead of inventing new APIs.
5. Keep extension state branch-aware where relevant by reconstructing from `ctx.sessionManager.getBranch()` on `session_start`.
6. Add cleanup on `session_shutdown` for timers, handles, child processes, sockets, or watchers.
7. Tell the user to run `/reload` after project-local changes.

## Safety rules

- Extensions run with full local privileges. Keep code minimal and auditable.
- If intercepting tools, fail safe: block dangerous ambiguous operations rather than allowing them.
- If a custom tool mutates files, use `withFileMutationQueue()` around the full read-modify-write window.
- If a custom tool returns large output, truncate it and save full output to a temp file.
- In non-interactive modes, check `ctx.hasUI` before relying on UI.
- For tool string enums, use `StringEnum` from `@earendil-works/pi-ai`, not `Type.Union`/`Type.Literal`.
- Signal tool failures by throwing an error from `execute()`.
- Normalize leading `@` in custom tool path parameters if accepting paths.

## Common examples to inspect

- Minimal tool: `hello.ts`
- Commands: `commands.ts`, `reload-runtime.ts`
- Permission gates: `permission-gate.ts`, `protected-paths.ts`
- Tool rendering/state: `todo.ts`
- Widgets/status: `status-line.ts`, `widget-placement.ts`, `working-indicator.ts`
- Custom footer/editor: `custom-footer.ts`, `modal-editor.ts`
- Autocomplete: `github-issue-autocomplete.ts`
- Providers: `custom-provider-anthropic/`, `custom-provider-gitlab-duo/`
- Full workflow: `plan-mode/`

## Validation

After editing:

```bash
pi --version
```

Then ask the user to run:

```text
/reload
```

If the extension has a package with dependencies, run installation in that extension/package directory first.
