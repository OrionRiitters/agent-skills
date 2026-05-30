---
name: pi-package-builder
description: Create, review, install, or publish pi packages containing extensions, skills, prompts, or themes. Use when bundling pi customizations for reuse via npm, git, local paths, or project settings.
---

# Pi Package Builder

Use this skill when a user wants to package pi resources or install/share pi functionality.

## Required reading before implementation

Read completely:

1. `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\packages.md`
2. If packaging extensions: `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\extensions.md`
3. If packaging skills: `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\skills.md`
4. If packaging themes: `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\themes.md`
5. If packaging prompts: `C:\Users\orion\.bun\install\global\node_modules\@earendil-works\pi-coding-agent\docs\prompt-templates.md`

## What can go in a pi package

A pi package can contain:

- `extensions/` — runtime behavior, tools, commands, UI, providers
- `skills/` — task-specific workflows and helper scripts
- `prompts/` — reusable prompt templates
- `themes/` — `.json` themes

## Basic package structure

```text
my-pi-package/
├── package.json
├── extensions/
│   └── my-extension.ts
├── skills/
│   └── my-skill/
│       └── SKILL.md
├── prompts/
│   └── review.md
└── themes/
    └── my-theme.json
```

## package.json template

```json
{
  "name": "my-pi-package",
  "version": "0.1.0",
  "description": "Pi package with extensions, skills, prompts, and themes.",
  "keywords": ["pi-package"],
  "license": "MIT",
  "type": "module",
  "pi": {
    "extensions": ["./extensions"],
    "skills": ["./skills"],
    "prompts": ["./prompts"],
    "themes": ["./themes"]
  },
  "peerDependencies": {
    "@earendil-works/pi-coding-agent": "*",
    "@earendil-works/pi-tui": "*",
    "@earendil-works/pi-ai": "*",
    "typebox": "*"
  }
}
```

Only include resource types that actually exist.

## Dependency rules

- Runtime dependencies needed by your package belong in `dependencies`.
- Pi core packages used by extensions belong in `peerDependencies` with `"*"`:
  - `@earendil-works/pi-coding-agent`
  - `@earendil-works/pi-tui`
  - `@earendil-works/pi-ai`
  - `@earendil-works/pi-agent-core`
  - `typebox`
- Do not rely on `devDependencies` at runtime.
- For git/npm packages, pi runs install automatically when needed.

## Install commands

Global install:

```bash
pi install npm:package-name
pi install git:github.com/user/repo
pi install /absolute/path/to/package
```

Project-local install:

```bash
pi install -l npm:package-name
pi install -l git:github.com/user/repo
pi install -l ./relative/path/to/package
```

Temporary test:

```bash
pi -e ./path/to/extension-or-package
```

## Settings filters

Use filters when only some package resources should load:

```json
{
  "packages": [
    {
      "source": "npm:my-package",
      "extensions": ["extensions/*.ts", "!extensions/legacy.ts"],
      "skills": [],
      "prompts": ["prompts/review.md"],
      "themes": ["+themes/dark.json"]
    }
  ]
}
```

## Security checklist

Before installing or recommending a package:

- Review extension code. Extensions execute with full local privileges.
- Review skills and helper scripts. Skills can instruct the model to run arbitrary commands.
- Check package dependencies and postinstall behavior.
- Prefer pinned versions/refs for team or CI use.
- Use project-local packages for project-specific behavior.

## Publication checklist

- Add `pi-package` keyword.
- Add a clear README with install commands.
- Include a `pi` manifest unless conventional directories are sufficient.
- Put runtime dependencies in `dependencies`.
- Keep examples minimal and safe.
- Mention required environment variables and external CLIs.
- Optionally add `pi.image` or `pi.video` metadata for package gallery preview.

## Reload/update guidance

After editing local resources:

```text
/reload
```

For installed packages:

```bash
pi list
pi update --extensions
```
