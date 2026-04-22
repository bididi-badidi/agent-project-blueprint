# Versioning Guidelines

This document defines how to version the Agent Project Blueprint — covering individual files, the project changelog, and git tags.

---

## How Versioning Works

The blueprint uses **two levels of versioning**:

| Level | Where | Purpose |
|---|---|---|
| **File version** | `version:` in each file's frontmatter | Tracks when a specific file was last changed |
| **Project release** | Git tag + `CHANGELOG.md` entry | Marks a named point in the project's history |

Files that are **not** changed in a release keep their existing version number. Only touched files get a bump.

---

## Semantic Versioning Rules

All versions follow `MAJOR.MINOR.PATCH`:

| Bump | When to use | Example |
|---|---|---|
| **PATCH** `x.x.1` | Typo fix, wording tweak, minor clarification | `1.0.0 → 1.0.1` |
| **MINOR** `x.1.x` | New section, new rule, meaningful addition that doesn't break existing behaviour | `1.0.0 → 1.1.0` |
| **MAJOR** `2.x.x` | Breaking restructure, removed sections, changes that significantly alter agent behaviour | `1.0.0 → 2.0.0` |

---

## Step-by-Step: Releasing a New Version

### Step 1 — Make your changes

Edit the relevant file(s): `GEMINI.md`, `CLAUDE.md`, or any `SKILL.md`.

---

### Step 2 — Bump the version in each changed file's frontmatter

For `GEMINI.md` and `CLAUDE.md`, update `version:`, `last_updated:`, and append to `changelog:`:

```yaml
---
version: 1.0.1
last_updated: 2026-04-25
changelog:
  - 1.0.1: Added new handover protocol rule
  - 1.0.0: Initial release
---
```

For `SKILL.md` files, update `version:` only:

```yaml
---
name: git-workflow
version: 1.0.1
description: "..."
---
```

> Files **not** changed in this release: leave their `version:` field as-is.

---

### Step 3 — Add an entry to `CHANGELOG.md`

Insert a new block at the **top** of the changelog (above the previous release):

```markdown
## v1.0.1 — YYYY-MM-DD

### Changed
- `GEMINI.md` — added new handover protocol rule
```

Use these section labels as needed:

| Label | When to use |
|---|---|
| `Added` | New files or new sections within a file |
| `Changed` | Modifications to existing content |
| `Fixed` | Corrected errors, broken instructions, or wrong examples |
| `Removed` | Deleted files or removed sections |

Only include labels that apply. Do not add empty sections.

---

### Step 4 — Commit

Stage only the files you changed plus `CHANGELOG.md`:

```bash
git add <changed files> CHANGELOG.md
git commit -m "docs(<scope>): <short description of what changed>"
```

Examples:
```bash
git commit -m "docs(gemini): add handover protocol rule"
git commit -m "docs(skills): bump git-workflow with ops type"
git commit -m "docs(claude): clarify safety rules section"
```

---

### Step 5 — Tag the release

```bash
git tag -a v1.0.1 -m "v1.0.1 — <one-line summary of what changed>"
git push origin v1.0.1
```

The tag version must match the new entry in `CHANGELOG.md`.

---

## Quick Reference

```
1. Edit file(s)
2. Bump version: in each changed file's frontmatter
3. Add entry at top of CHANGELOG.md
4. git add <files> CHANGELOG.md
5. git commit -m "docs(<scope>): <description>"
6. git tag -a v<x.y.z> -m "v<x.y.z> — <summary>"
7. git push origin v<x.y.z>
```

---

## Example: Only One File Changed

GEMINI.md is updated in v1.0.1. Skills are untouched.

| File | Before | After |
|---|---|---|
| `GEMINI.md` | `version: 1.0.0` | `version: 1.0.1` |
| `CLAUDE.md` | `version: 1.0.0` | `version: 1.0.0` ← unchanged |
| `git-workflow/SKILL.md` | `version: 1.0.0` | `version: 1.0.0` ← unchanged |

`CHANGELOG.md` entry:
```markdown
## v1.0.1 — 2026-04-25

### Changed
- `GEMINI.md` — added handover protocol rule
```

Git tag: `v1.0.1`
