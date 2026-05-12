# Changelog

All notable changes to the Agent Project Blueprint will be documented here.

Format: `## vX.Y.Z — YYYY-MM-DD` with sections `Added`, `Changed`, `Fixed`, `Removed`.
Version in each file's frontmatter reflects the last release in which that file was modified.

---

## v2.0.0 — 2026-05-12

### Changed

- `.claude/skills/git-workflow/SKILL.md` — rewritten to cover the full git lifecycle (branch → commit → push → PR → merge → cleanup); absorbs content from `git-branching` and `pull-requests` into a single skill with one shared Conventional Commits reference (v1.0.0 → v2.0.0)
- `.gemini/skills/git-workflow/SKILL.md` — same as above (v1.0.0 → v2.0.0)
- `.agents/skills/git-workflow/SKILL.md` — same as above (v1.0.0 → v2.0.0)

### Removed

- `.claude/skills/git-branching/SKILL.md` — consolidated into `git-workflow`
- `.claude/skills/pull-requests/SKILL.md` — consolidated into `git-workflow`
- `.gemini/skills/git-branching/SKILL.md` — consolidated into `git-workflow`
- `.gemini/skills/pull-requests/SKILL.md` — consolidated into `git-workflow`
- `.agents/skills/git-branching/SKILL.md` — consolidated into `git-workflow`
- `.agents/skills/pull-requests/SKILL.md` — consolidated into `git-workflow`

---

## v1.1.0 — 2026-05-11

### Added

- `AGENTS.md` — initial Codex-compatible project instructions
- `.agents/skills/*/SKILL.md` — Codex repository-scoped copies of the bundled skills
- `.codex/config.toml` — project-scoped Codex MCP configuration for shared memory

### Changed

- `README.md` — document Codex, AGENTS.md, skills, and MCP support
- `install.sh` — install Codex files during fresh installs and upgrades
- `install.ps1` — install Codex files during fresh installs and upgrades
- `init_project.sh` — scaffold Codex directories, MCP config, skills, and `AGENTS.md`
- `init_ai.sh` — scaffold Codex MCP config, skills, and `AGENTS.md`

### Fixed

- `.gemini/settings.json` — point memory MCP at shared `.ai/assets/memory.jsonl`
- `.claude/settings.json` — populate the memory MCP settings file

## v1.0.1 — 2026-04-22

### Changed

- `CLAUDE.md` — compress section 0.1-0.3 to one file hygiene section
- `GEMINI.md` — compress section 0.1-0.3 to one file hygiene section

## v1.0.0 — 2026-04-22

### Added

- `CLAUDE.md` — initial agent instructions for Claude
- `GEMINI.md` — initial agent instructions for Gemini
- `.claude/skills/coding-workflow/SKILL.md`
- `.claude/skills/git-branching/SKILL.md`
- `.claude/skills/git-workflow/SKILL.md`
- `.claude/skills/github-workflows/SKILL.md`
- `.claude/skills/pull-requests/SKILL.md`
- `.claude/skills/task-decompose/SKILL.md`
- `.claude/skills/write-skills/SKILL.md`
- `.gemini/skills/coding-workflow/SKILL.md`
- `.gemini/skills/git-branching/SKILL.md`
- `.gemini/skills/git-workflow/SKILL.md`
- `.gemini/skills/github-workflows/SKILL.md`
- `.gemini/skills/pull-requests/SKILL.md`
- `.gemini/skills/task-decompose/SKILL.md`
- `.gemini/skills/write-skills/SKILL.md`
