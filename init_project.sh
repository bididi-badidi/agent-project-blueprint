#!/bin/bash

# Define the base directories
AI_DIR=".ai/assets"
AGENTS_DIR=".agents"
CODEX_DIR=".codex"
GEMINI_DIR=".gemini"
CLAUDE_DIR=".claude"
SCRIPTS_DIR=".ai/scripts"

echo "🚀 Initializing project scaffolding (.ai, .agents, .codex, .gemini, .claude)..."

# 1. Create Core Directory Tree
mkdir -p "$AI_DIR/phases" "$AI_DIR/branches" "$AI_DIR/examples" "$SCRIPTS_DIR"
mkdir -p "$AGENTS_DIR/skills/coding-workflow"
mkdir -p "$CODEX_DIR"
mkdir -p "$GEMINI_DIR/skills/coding-workflow"
mkdir -p "$CLAUDE_DIR/skills/coding-workflow"
mkdir -p "$CLAUDE_DIR/rules" "$CLAUDE_DIR/agent-memory"

# 2. .ai Boilerplate
if [ ! -f "$AI_DIR/progress.md" ]; then
cat <<EOF > "$AI_DIR/progress.md"
# Project Progress

## Current Task
- [ ] Project Setup & Initialization

## Upcoming
- Phase 1: Research & Setup

## Project Documents
- [Architecture & Plan](.ai/assets/PLAN.md)
- [Session Notes](.ai/assets/session_notes.md)
- [Backlog](.ai/assets/backlog.md)
EOF
fi

[ ! -f "$AI_DIR/PLAN.md" ] && echo "# Project Plan" > "$AI_DIR/PLAN.md"
[ ! -f "$AI_DIR/backlog.md" ] && echo "# Project Backlog" > "$AI_DIR/backlog.md"
touch "$AI_DIR/memory.jsonl"

# 3. .gemini Boilerplate (Settings & Memory MCP)
if [ ! -f "$GEMINI_DIR/settings.json" ]; then
cat <<EOF > "$GEMINI_DIR/settings.json"
{
  "mcp": {
    "allowed": ["memory"],
    "excluded": []
  },
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {
        "MEMORY_FILE_PATH": ".ai/assets/memory.jsonl"
      }
    }
  }
}
EOF
fi

# 4. Standard Skill: Coding Workflow
SKILL_PATH="skills/coding-workflow/SKILL.md"
if [ ! -f "$GEMINI_DIR/$SKILL_PATH" ]; then
cat <<EOF > "$GEMINI_DIR/$SKILL_PATH"
---
name: coding-workflow
description: Enforces linting, testing, and git hygiene after every code change.
---
# Post-Coding Workflow
1. **Linting**: Run project-specific linting (e.g., \`ruff check .\`).
2. **Testing**: Run test suite (e.g., \`pytest\`).
3. **Git Hygiene**: Check for untracked files and update .gitignore.
EOF
fi
[ ! -f "$CLAUDE_DIR/$SKILL_PATH" ] && cp "$GEMINI_DIR/$SKILL_PATH" "$CLAUDE_DIR/$SKILL_PATH"
[ ! -f "$AGENTS_DIR/$SKILL_PATH" ] && cp "$GEMINI_DIR/$SKILL_PATH" "$AGENTS_DIR/$SKILL_PATH"

# 5. .codex Boilerplate (Project MCP)
if [ ! -f "$CODEX_DIR/config.toml" ]; then
cat <<EOF > "$CODEX_DIR/config.toml"
# Project-scoped Codex configuration.
# Codex loads this file after the user trusts the project.

[mcp_servers.memory]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-memory"]

[mcp_servers.memory.env]
MEMORY_FILE_PATH = ".ai/assets/memory.jsonl"
EOF
fi

# 6. .claude Boilerplate
[ ! -f "$CLAUDE_DIR/settings.json" ] && cp "$GEMINI_DIR/settings.json" "$CLAUDE_DIR/settings.json"

# 7. Global Rules (AGENTS.md, GEMINI.md)
if [ ! -f "AGENTS.md" ]; then
cat <<EOF > "AGENTS.md"
# Local Coder Agent
- **Mandate**: Refer to \`.ai/assets/progress.md\`, \`.ai/assets/PLAN.md\`, and \`.ai/assets/session_notes.md\` at the start of every session.
- **Workflow**: Plan -> Act -> Validate.
- **Handover**: Use \`.ai/assets/session_notes.md\` for session state.
- **Skills**: Repository-scoped Codex skills live in \`.agents/skills/\`.
- **MCP**: Project-scoped Codex MCP configuration lives in \`.codex/config.toml\`.
EOF
fi

if [ ! -f "GEMINI.md" ]; then
cat <<EOF > "GEMINI.md"
# Local Coder Agent
- **Mandate**: Refer to \`.ai/assets/progress.md\` at the start of every session.
- **Workflow**: Plan -> Act -> Validate.
- **Handover**: Use \`.ai/assets/session_notes.md\` for session state.
EOF
fi

echo "✅ Project initialized successfully!"
