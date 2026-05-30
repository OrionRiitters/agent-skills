---
name: pi-config-sync
description: Manually sync pi configuration resources with a GitHub repository. Use when pulling, pushing, bootstrapping, installing, or checking status for pi skills, extensions, prompts, themes, settings, AGENTS.md, SYSTEM.md, APPEND_SYSTEM.md, or keybindings stored in git. Use this for copying shared skills into project-local or global pi skill directories while preserving source namespaces such as anthropic/, pi/, and orion/.
---

# Pi Config Sync

Use this skill when the user wants to store or retrieve pi configuration through GitHub/git.

This is an explicit, manual workflow. Do not auto-sync. Always confirm before pushing changes.

## Scope qualifiers

Interpret skill location qualifiers exactly:

- **local skill**: the skill as it exists in the current project under `.pi/skills/`.
- **global skill**: the skill as it exists on this machine under `~/.pi/agent/skills/`.
- **repo skill**: the skill as it exists in the `shared-pi-config` GitHub repository checkout under `skills/`.

When the user refers to a skill without a `local`, `global`, or `repo` qualifier, update that skill in every place it exists: local project, global machine config, and/or the shared-pi-config repo. First discover all matching copies, then apply the same intended change to each copy that exists.

When the user explicitly says `local`, update only the current project copy. When they explicitly say `global`, update only the machine-global copy. When they explicitly say `repo`, update only the shared-pi-config repository copy.

Preserve the namespace path in all locations. For example, `pi-config-sync` should be checked as `orion/pi-config-sync`, `algorithmic-art` as `anthropic/algorithmic-art`, and `brave-search` as `pi/brave-search`.



## Repository layout convention

Shared skills in this repository live under source/owner namespaces:

```text
skills/
├── anthropic/
│   └── algorithmic-art/
│       └── SKILL.md
├── pi/
│   └── brave-search/
│       └── SKILL.md
└── orion/
    └── pi-config-sync/
        └── SKILL.md
```

When copying skills into a local pi skill directory, preserve this tree below the target skill root:

```text
.pi/skills/anthropic/algorithmic-art/SKILL.md
.pi/skills/pi/brave-search/SKILL.md
.pi/skills/orion/pi-config-sync/SKILL.md
```

For global/user installs, preserve the same tree under:

```text
~/.pi/agent/skills/anthropic/algorithmic-art/SKILL.md
~/.pi/agent/skills/pi/brave-search/SKILL.md
~/.pi/agent/skills/orion/pi-config-sync/SKILL.md
```

Do **not** flatten skills into `.pi/skills/<skill-name>` when pulling from this repository, because flattening loses provenance and can create name/path collisions.

## Directory structure reconciliation

The target skill tree must mirror the repository skill tree under `skills/`.

When pulling skills from the repo into local or global pi config:

1. Treat `repo/skills/` as the source root.
2. Treat `.pi/skills/` or `~/.pi/agent/skills/` as the target root.
3. Copy each skill to the same relative path it has under `repo/skills/`.
4. If an older flattened copy exists at the target root, move or replace it with the namespaced copy.

Examples:

```text
repo/skills/anthropic/skill-creator/SKILL.md
→ .pi/skills/anthropic/skill-creator/SKILL.md
→ ~/.pi/agent/skills/anthropic/skill-creator/SKILL.md

repo/skills/orion/pi-config-sync/SKILL.md
→ .pi/skills/orion/pi-config-sync/SKILL.md
```

When pushing skills from local/global config back to the repo:

1. Preserve the relative path under the local/global skill root.
2. Write to the same relative path under `repo/skills/`.
3. Do not push a namespaced local skill into a flattened repo path.
4. If the repo contains an older flattened copy, move or replace it with the namespaced path before committing.

For example, pushing `.pi/skills/anthropic/skill-creator` must update `repo/skills/anthropic/skill-creator`, not `repo/skills/skill-creator`.

Before finishing a pull or push, check for common flattened duplicates such as `.pi/skills/skill-creator` when `repo/skills/anthropic/skill-creator` exists, and report/fix the mismatch.

## What belongs in the config repo

Good candidates:

- `skills/` with source-scoped skill directories such as `skills/anthropic/`, `skills/pi/`, `skills/orion/`
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
./scripts/install-skills.sh [repo-checkout] [project|global|target-skill-root] [skill-relative-path...]
./scripts/push-config.sh [dest-dir] [commit-message]
```

Examples:

```bash
# Pull or update the shared config checkout
./scripts/pull-config.sh https://github.com/OrionRiitters/shared-pi-config.git ~/.pi/agent/config-repo

# Install all shared skills into the current project, preserving namespaces
./scripts/install-skills.sh ~/.pi/agent/config-repo project

# Install one skill into the current project as .pi/skills/orion/pi-config-sync
./scripts/install-skills.sh ~/.pi/agent/config-repo project orion/pi-config-sync

# Install one skill globally as ~/.pi/agent/skills/anthropic/algorithmic-art
./scripts/install-skills.sh ~/.pi/agent/config-repo global anthropic/algorithmic-art

./scripts/status-config.sh ~/.pi/agent/config-repo
./scripts/push-config.sh ~/.pi/agent/config-repo "Update pi config"
```

## Pull workflow

1. Identify the repo URL and checkout directory.
2. Run `pull-config.sh`.
3. Inspect the checked-out files before enabling any new extensions or skills.
4. For pi package installation, recommend:

   ```bash
   pi install git:github.com/OrionRiitters/shared-pi-config
   ```

5. For direct skill copying, use `install-skills.sh` and preserve the repo's skill namespace tree:
   - project-local target: `.pi/skills/`
   - global/user target: `~/.pi/agent/skills/`
   - example resulting path: `.pi/skills/orion/pi-config-sync/SKILL.md`
6. If loading paths manually, update `~/.pi/agent/settings.json` or project `.pi/settings.json` with the relevant resource paths.
7. Ask the user to run `/reload` so pi discovers updated resources.

## Skill install workflow

When the user asks to pull a skill into a project or global/user config:

1. Pull/update the shared config checkout with `pull-config.sh`.
2. Determine the source-relative skill path under `skills/`, for example:
   - `orion/pi-config-sync`
   - `anthropic/algorithmic-art`
   - `pi/brave-search`
3. Determine the target root:
   - project-local: `.pi/skills`
   - global/user: `~/.pi/agent/skills`
4. Copy the skill so the source-relative path is preserved under the target root.
5. Report the exact installed path and ask the user to run `/reload`.

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
