---
name: project-context-maintenance
description: Use this skill when creating, updating, moving, renaming, or deleting project source files in repositories that use sidecar documentation, file summaries, or retrieval docs. It keeps the project's context index synchronized with code by creating, updating, moving, or deleting concise sidecar docs when source changes affect file discovery, purpose, exports, dependencies, side effects, or relevance guidance. Do not use it for formatting-only changes, tiny copy edits, or repos with no sidecar-doc convention unless the user explicitly asks for docs.
---

# Project Context Maintenance

Keep retrieval-oriented project docs synchronized with source changes. Sidecar docs are an index for future agents and developers: they should help decide which files to inspect, not duplicate the implementation.

Use this skill after or alongside code edits when the repository has a sidecar-doc convention such as `file.ext.md`, `file.summary.md`, nearby module `README.md`, generated file maps, or other per-file summaries.

## Quick decision rules

- If you create a meaningful source file and the project uses sidecar docs, create the matching sidecar doc.
- If you update a source file and its sidecar doc exists, update the doc only when retrieval-relevant facts changed.
- If you update a source file, no sidecar exists, and the surrounding project clearly uses sidecars, create one using the local convention.
- If you move or rename a source file, move or rename the sidecar doc too and update its path/title/references.
- If you delete a source file, delete its matching sidecar doc and remove obvious references from nearby module docs.
- Skip sidecar updates for formatting-only changes, internal refactors that do not change purpose/API/side effects/relevance, tiny text changes, or generated/vendor/build artifacts.

## Find and follow the local convention

Before creating or renaming docs, inspect nearby files to infer the convention. Prefer the closest existing pattern over a global guess.

Common patterns:

- `path/to/file.ext.md`
- `path/to/file.summary.md`
- `path/to/file.md`
- Directory-level `README.md`, `index.md`, or module summary files

If multiple conventions exist, follow the one used in the same directory or module. If no convention exists in the repo, do not introduce one unless the user asks.

Useful commands:

```bash
# Look for nearby sidecars and module docs
find path/to/dir -maxdepth 2 \( -iname '*.summary.md' -o -iname '*.md' -o -iname 'README*' \)

# Look for repo-wide sidecar patterns
find . \( -iname '*.summary.md' -o -iname '*.md' \) | rg '(\.summary\.md$|\.[^.]+\.md$|/README)'
```

Avoid noisy generated/vendor/build directories unless the task specifically concerns them.

## When to update a sidecar doc

Update or create sidecar documentation when the source change affects any of these retrieval signals:

- **Purpose/responsibility:** the file now owns a different feature, behavior, component, command, route, model, or service.
- **Exports / entry points:** public functions, classes, components, commands, routes, config keys, or module exports were added, removed, renamed, or materially changed.
- **Used by / depends on:** important callers, callees, imports, framework registrations, routes, or module relationships changed.
- **Side effects:** database writes, filesystem access, network calls, cookies, caches, environment variables, global state, telemetry, jobs, queues, or UI state changed.
- **Relevant when:** future tasks/symptoms where this file should be inspected changed.
- **Not relevant / see also:** common confusions, redirects, or boundaries changed.

Do not update a sidecar solely because line-level implementation details changed. The doc should stay stable unless future retrieval would benefit.

## Creating a sidecar doc

Keep sidecars short, accurate, and structured. Include only sections that add useful retrieval signal.

```md
# path/to/file.ext

Purpose: One or two sentences describing the file's responsibility.

Exports / entry points:
- name: what it does

Used by:
- path or module

Side effects:
- Important IO, state, network, database, cache, environment, UI effects

Relevant when:
- Tasks or symptoms where this file should be read

Not relevant / see also:
- Clarify common confusions and better files to inspect
```

Prefer concrete names and paths over vague descriptions. Avoid copying code, listing every private helper, or writing broad statements like “contains utilities.”

## Updating an existing sidecar doc

1. Read the source file you changed.
2. Read the existing sidecar doc.
3. Compare the edit against retrieval signals: purpose, API, relationships, side effects, relevance guidance.
4. Make the smallest doc update that keeps future retrieval accurate.
5. If the source contradicts the sidecar, trust source and remove stale claims.

Keep unrelated parts intact unless they are stale or misleading.

## Moving, renaming, or deleting files

When moving or renaming source:

- Move/rename the sidecar doc using the same convention.
- Update the heading/path inside the sidecar.
- Update obvious references in nearby module docs or sidecars.
- If the move changes module ownership or relevance, update those sections too.

When deleting source:

- Delete the matching sidecar doc if it exists.
- Remove obvious references from nearby module docs, indexes, or “see also” sections.
- Do not leave orphan sidecars for deleted implementation files.

## Reporting to the user

Briefly mention doc maintenance only when useful:

- Created sidecar doc: `path/to/file.ext.md`
- Updated sidecar doc because exports/side effects/relevance changed
- Moved/deleted sidecar doc to match source
- Skipped sidecar update because the change did not affect retrieval-relevant facts

Keep the report concise; the main output is synchronized code and context docs.
