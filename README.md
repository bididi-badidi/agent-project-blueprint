# Agent Project Blueprint

A template for project-aware coding agents (Gemini CLI, Claude Code, etc.). This blueprint provides a structured way to manage project progress, session notes, and specialized agent skills.

## ✨ Features

- **Project Tracking:** Structured `.ai/` directory for plans, progress, and backlog.
- **Agent Rules:** Foundation `GEMINI.md` and `CLAUDE.md` files to guide agent behavior.
- **Custom Skills:** Pre-configured skills for git workflows, pull requests, and more.
- **Session Handover:** A robust protocol for passing context between different agent sessions.

## 🚀 Quick Start for Existing Projects

If you have an existing project and want to add this blueprint structure, run the command for your operating system in your project root.

### macOS / Linux

```bash
# Latest release
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)"

# Specific version
bash -c "$(curl -fsSL https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.sh)" -- --version v1.0.0
```

### Windows (PowerShell)

```powershell
# Latest release
powershell -c "irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1 | iex"

# Specific version
powershell -c "& { $(irm https://raw.githubusercontent.com/bididi-badidi/agent-project-blueprint/main/install.ps1) } -Version v1.0.0"
```

> Available versions: [Releases](https://github.com/bididi-badidi/agent-project-blueprint/releases)

### Upgrading

Re-run the install command with the new version. The script detects your currently installed version (tracked in `.ai/assets/.blueprint-version`) and stages updated files alongside your existing ones as `.upstream` copies, so you can review and merge changes before deleting them.

## 📂 Directory Structure

- `.ai/`: Project management assets (progress, plans, notes).
- `.gemini/`: Settings and skills for Gemini CLI.
- `.claude/`: Settings and skills for Claude Code.
- `GEMINI.md`: Core instructions for Gemini CLI.
- `CLAUDE.md`: Core instructions for Claude Code.

## 🛠️ Included Skills

- `coding-workflow`: Automated linting and testing checks.
- `git-workflow`: Semantic commit message generation.
- `git-branching`: Intelligent branch management.
- `github-workflows`: CI/CD automation.
- `pull-requests`: PR description and review assistance.
- `task-decompose`: Breaking down complex tasks into actionable steps.
- `write-skills`: Tools for creating and refining agent skills.

## 📖 License

MIT
