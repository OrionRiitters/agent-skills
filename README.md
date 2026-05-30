# Shared Pi Config

This repository stores reusable pi configuration and related agent resources.

It is intended to be a central, reviewable place for configuration that can be shared across machines, projects, and agent environments.

## Contents

- `anthropic/` — skills mirrored from [`anthropics/skills`](https://github.com/anthropics/skills)
- `pi/` — skills mirrored from [`badlogic/pi-skills`](https://github.com/badlogic/pi-skills)
- `orion/` — Orion's custom skills
- `extensions/` — shared pi TypeScript extensions
- `prompts/` — shared pi prompt templates
- `themes/` — shared pi themes
- `settings/` — safe settings snippets and examples

## Install as a pi package

```bash
pi install git:github.com/OrionRiitters/shared-pi-config
```

Pin to a commit or tag for reproducible setups:

```bash
pi install git:github.com/OrionRiitters/shared-pi-config@<commit-or-tag>
```

The root `package.json` exposes skills, extensions, prompts, and themes through pi's package mechanism.

## Manual sync

The `orion/pi-config-sync` skill provides an explicit git-based workflow for pulling, checking, committing, and pushing updates to this repository.

## Safety and attribution

- Review third-party skills and extensions before enabling them.
- Keep attribution, source metadata, and license files with imported third-party content.
- Do not commit API keys, OAuth tokens, credentials, private session history, or machine-local secrets.
