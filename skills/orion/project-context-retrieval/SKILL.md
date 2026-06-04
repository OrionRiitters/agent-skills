---
name: project-context-retrieval
description: Use this skill when a coding task requires nontrivial file discovery, project understanding, or careful context selection before answering or editing code. This includes debugging, implementing features, refactoring, reviewing code, tracing behavior, or deciding which source files to read in large or unfamiliar repositories. It is especially important when the target files are ambiguous, sidecar documentation or file summaries exist, architectural context matters, or context budget matters. Do not use it for obvious localized tasks where the user names the exact small file/symbol and direct source inspection is cheaper.
---

# Project Context Retrieval

Use project documentation as a retrieval index before reading source, while treating docs as guidance rather than truth. The goal is to spend context on the files most likely to matter, then verify against actual code before making claims or edits. Keep the workflow proportional: for small, obvious tasks, direct source inspection is often the most context-efficient retrieval strategy.

## Quick decision rules

- **Use the fast path for localized tasks:** if the user names a specific small file, exact symbol, obvious config key, or clearly localized change, inspect that source directly first instead of spending context on project maps or summaries.
- Escalate from the fast path to broader retrieval only when the target file is large, the first source read reveals ambiguity, the change depends on callers/callees/tests, or architectural/project context is needed.
- If a stack trace, failing test, user prompt, or search result names a source file or symbol, inspect that source even if docs suggest it is unrelated.
- If sidecar docs exist and file selection is nontrivial, read them early to rank files, but do not let them veto strong evidence from code, tests, imports, or runtime errors.
- If you will edit a file or make a concrete implementation claim, verify the relevant facts in source first.
- If the source contradicts a summary, trust source and treat the summary as stale or incomplete.

## Core workflow

1. **Clarify the task target and choose scope**
   - Identify the feature, bug, module, symbol, path, framework, or user-facing behavior involved.
   - Extract likely search terms: domain words, route names, class/function names, config keys, error messages, tests, and package names.
   - Decide whether this is a fast-path task or a retrieval task:
     - Fast path: exact small file/symbol/localized edit is already named; read that source first.
     - Retrieval path: relevant files are uncertain, the repo is large/unfamiliar, summaries exist, or cross-file behavior matters.

2. **For fast-path tasks, start at the named source**
   - Read the directly named file or search the exact named symbol/path.
   - Add only the nearest related files needed to be correct: a focused test, caller, callee, config, or sidecar doc.
   - Do not read project-level docs just because they exist; switch to broader retrieval only if the first source read shows the task is less localized than it appeared.

3. **For retrieval tasks, start with project maps and summary docs**
   - Look for high-level files first: `README*`, `ARCHITECTURE*`, `CONTRIBUTING*`, `docs/`, directory `README*`, module docs, or generated project maps.
   - If the repo has per-file sidecar docs, prefer reading those before source files unless strong evidence already identifies a source file.
   - Common sidecar patterns include:
     - `path/to/file.ext.md`
     - `path/to/file.md`
     - `path/to/file.summary.md`
     - nearby `README.md` or `index.md`

4. **Use summaries to prioritize, not exclude**
   - Treat summaries as a cheap semantic index.
   - Do not assume they are complete or current.
   - If the task strongly suggests a file is relevant by name, imports, tests, stack trace, or search hits, inspect the source even if the summary seems unrelated.

5. **Prefer hierarchical narrowing**
   - Read in this order when available:
     1. Project-level overview
     2. Directory/module overview
     3. Per-file summaries
     4. Selected source files
     5. Related tests/config/callers/callees
   - This reduces over-reading while preserving architectural context.

6. **Verify against source before editing or final claims**
   - Before modifying a file, read the actual source file.
   - Before explaining implementation details, verify the details in source.
   - Use docs to decide what to read; use code to decide what is true.

## What to look for in sidecar docs

When evaluating summary docs, prioritize files whose docs mention:

- **Purpose/responsibility** matching the task.
- **Exports or public API** relevant to the requested change.
- **Used by / depends on** relationships that connect to the target behavior.
- **Side effects** such as database writes, filesystem access, network calls, cookies, caches, environment variables, or UI state.
- **Relevant when** guidance that matches the user's request.
- **Not relevant / see also** guidance that redirects to better files.

If summaries are too generic, stale-looking, or contradictory, fall back to source search and code inspection.

## Large-repo context economy patterns

- Use directory shape and search snippets as cheap filters before opening files.
- Rank search hits; read only the strongest candidates first.
- Prefer exact symbol/string/route searches over broad browsing.
- Search tests early when behavior, regressions, or expected output matters.
- Expand through imports, callers, callees, route registration, and tests rather than file proximity.
- Exclude generated/vendor/build directories by default unless the task specifically concerns them.
- Reassess after each file whether more context is needed.
- Keep a small working set: confirmed relevant, maybe relevant, rejected.

## Search strategy

Use a layered search instead of opening many files blindly:

1. Search documentation and sidecar summaries for task terms.
2. Search filenames and paths.
3. Search source for exact symbols, error text, route names, config keys, or UI labels.
4. Search tests for expected behavior.
5. Trace imports/callers/callees from the most promising files.

Good commands include `rg`, `find`, and targeted reads. Avoid reading large files end-to-end unless needed; read relevant sections first when the tool supports offsets.

Useful command patterns:

```bash
# Find high-level docs and directory overviews
find . -iname 'README*' -o -iname 'ARCHITECTURE*' -o -path './docs/*'

# Find common sidecar summaries
find . \( -iname '*.summary.md' -o -iname '*.md' \) | rg '(/README|\.summary\.md$|\.[^.]+\.md$)'

# Search docs/summaries first, then source/tests
rg -i "logout|session|cookie" --glob '*.md'
rg -i "logout|session|cookie" --glob '!node_modules' --glob '!dist'

# Trace a named symbol from an error or prompt
rg "parseConfig" .
```

Adapt these to the repository and avoid noisy generated/vendor directories.

## Staleness checks

Be alert for stale docs. Red flags include:

- Summary names exports that are not in the source.
- Source imports/dependencies not reflected in docs.
- Recent source changes without matching doc changes, if git history/status is available.
- Summary describes broad intent but omits the exact behavior under investigation.
- Multiple summaries disagree.

When staleness matters, say so briefly and rely on source.

## Context selection heuristics

Pull a source file into context when any of these are true:

- It directly implements the feature, bug, route, component, command, model, or API involved.
- It defines a symbol named in the prompt, stack trace, test, or search result.
- It is a caller/callee of an already relevant file.
- It contains side effects related to the task.
- It is a test or fixture describing expected behavior.
- Its summary says it is relevant, but only after confirming with source if acting on details.

Avoid pulling a file solely because:

- It has a vague summary like “utilities” or “main component.”
- It is nearby but not connected by imports, tests, docs, or search hits.
- It is a generated/vendor/build artifact unless the task specifically concerns generated output.

## Editing behavior

Before editing:

1. Read the target source file.
2. Read closely related tests or callers when available.
3. Check whether an accompanying sidecar doc exists.
4. If the edit changes the file’s purpose, exports, side effects, dependencies, or relevance guidance, update the sidecar doc too.

When creating or updating a sidecar doc, keep it concise and structured:

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

Only include sections that add useful retrieval signal. Prefer accurate and brief over exhaustive.

## Reporting to the user

When useful, summarize your retrieval path briefly:

- Which docs/summaries you used to narrow the search.
- Which source files you verified.
- Any stale or missing documentation discovered.

Keep this concise; the main value is better context selection, not a long audit trail.
