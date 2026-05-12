# Agent Project Blueprint

A template for project-aware coding agents (Codex, Gemini CLI, Claude Code, etc.). This blueprint provides a structured way to manage project progress, session notes, MCP configuration, and specialized agent skills.

## ✨ Features

- **Project Tracking:** Structured `.ai/` directory for plans, progress, and backlog.
- **Agent Rules:** Foundation `AGENTS.md`, `GEMINI.md`, and `CLAUDE.md` files to guide agent behavior.
- **Custom Skills:** Pre-configured skills for Codex, Gemini CLI, and Claude Code workflows.
- **MCP Support:** Shared memory MCP configuration for agent-accessible project context.
- **Session Handover:** A robust protocol for passing context between different agent sessions.

## 🚀 Quick Start for Existing Projects

If you have an existing project and want to add this blueprint structure, run the command for your operating system in your project root.

### macOS / Linux

```bash
# All services (default)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)"

# Specific version
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)" -- --version v1.0.0

# Selected services only (codex, gemini, claude — mix and match)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)" -- --service claude
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)" -- --service codex,gemini
```

### Windows (PowerShell)

```powershell
# All services (default)
powershell -c "irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1 | iex"

# Specific version
powershell -c "& { $(irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1) } -Version v1.0.0"

# Selected services only (codex, gemini, claude — mix and match)
powershell -c "& { $(irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1) } -Services claude"
powershell -c "& { $(irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1) } -Services codex,gemini"
```

> Available versions: [Releases](https://github.com/bididi-badidi/agent-project-blueprint/releases)

### Upgrading

Re-run the install command with the new version. The script detects your currently installed version (tracked in `.ai/assets/.blueprint-version`) and stages updated files alongside your existing ones as `.upstream` copies, so you can review and merge changes before deleting them.

## 📂 Directory Structure

- `.ai/`: Project management assets (progress, plans, notes).
- `.agents/`: Repository-scoped Codex skills.
- `.codex/`: Project-scoped Codex configuration, including MCP servers.
- `.gemini/`: Settings and skills for Gemini CLI.
- `.claude/`: Settings and skills for Claude Code.
- `AGENTS.md`: Core instructions for Codex and other agents that support the AGENTS.md convention.
- `GEMINI.md`: Core instructions for Gemini CLI.
- `CLAUDE.md`: Core instructions for Claude Code.

## 🛠️ Included Skills

- `coding-workflow`: Automated linting and testing checks.
- `git-workflow`: Semantic commit message generation.
- `github-workflows`: CI/CD automation.
- `task-decompose`: Breaking down complex tasks into actionable steps.
- `write-skills`: Tools for creating and refining agent skills.

## 📖 License

MIT
