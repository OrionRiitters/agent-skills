---
name: pi-config-sync
description: Manually sync pi configuration resources with a GitHub repository. Use when pulling, pushing, bootstrapping, or checking status for pi skills, extensions, prompts, themes, settings, AGENTS.md, SYSTEM.md, APPEND_SYSTEM.md, or keybindings stored in git.
---

# Pi Config Sync

Use this skill when the user wants to store or retrieve pi configuration through GitHub/git.

This is an explicit, manual workflow. Do not auto-sync. Always confirm before pushing changes.

## What belongs in the config repo

Good candidates:

- `skills/` or source-scoped skill directories such as `anthropic/`, `pi/`, `orion/`
- `extensions/`
- `prompts/`
- `themes/`
- `AGENTS.md`
- `SYSTEM.md`
- `APPEND_SYSTEM.md`
- `keybindings.json`
- shareable `settings.json` package/resource lists

Do not commit secrets:

- API keys
- OAuth tokens
- credentials
- private session history unless explicitly requested
- machine-specific absolute paths unless intentional

## Default repository

If the user does not provide a repository, use:

```text
https://github.com/OrionRiitters/shared-pi-config.git
```

Default local checkout:

```text
~/.pi/agent/config-repo
```

## Commands

From this skill directory, use the helper scripts:

```bash
./scripts/pull-config.sh [repo-url] [dest-dir]
./scripts/status-config.sh [dest-dir]
./scripts/push-config.sh [dest-dir] [commit-message]
```

Examples:

```bash
./scripts/pull-config.sh https://github.com/OrionRiitters/shared-pi-config.git ~/.pi/agent/config-repo
./scripts/status-config.sh ~/.pi/agent/config-repo
./scripts/push-config.sh ~/.pi/agent/config-repo "Update pi config"
```

## Pull workflow

1. Identify the repo URL and destination directory.
2. Run `pull-config.sh`.
3. Inspect the checked-out files before enabling any new extensions or skills.
4. If the repo is a pi package, recommend installing it with:

   ```bash
   pi install git:github.com/OrionRiitters/shared-pi-config
   ```

5. If loading paths manually, update `~/.pi/agent/settings.json` or project `.pi/settings.json` with the relevant resource paths.
6. Ask the user to run `/reload` so pi discovers updated resources.

## Push workflow

1. Run `status-config.sh` to review changes.
2. Check for secrets before committing:
   - scan changed files for tokens, API keys, `.env`, auth files, and session data
   - do not commit credentials
3. Ask the user for explicit confirmation before pushing.
4. Run `push-config.sh` with a clear commit message.
5. Report the resulting commit hash and remote branch.

## Safety notes

- Skills can instruct agents to run commands, and extensions execute local code. Review third-party content before enabling it.
- Prefer pinned commits/tags for team or reproducible environments.
- Keep machine-local credentials outside the config repository.
