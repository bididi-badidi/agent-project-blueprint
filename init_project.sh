#!/bin/bash

# Define the base directories
AI_DIR=".ai/assets"
GEMINI_DIR=".gemini"
CLAUDE_DIR=".claude"
SCRIPTS_DIR=".ai/scripts"

echo "🚀 Initializing project scaffolding (.ai, .gemini, .claude)..."

# 1. Create Core Directory Tree
mkdir -p "$AI_DIR/phases" "$AI_DIR/branches" "$AI_DIR/examples" "$SCRIPTS_DIR"
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
cp "$GEMINI_DIR/$SKILL_PATH" "$CLAUDE_DIR/$SKILL_PATH"
fi

# 5. .claude Boilerplate
[ ! -f "$CLAUDE_DIR/settings.json" ] && cp "$GEMINI_DIR/settings.json" "$CLAUDE_DIR/settings.json"

# 6. Global Rules (GEMINI.md)
if [ ! -f "GEMINI.md" ]; then
cat <<EOF > "GEMINI.md"
# Local Coder Agent
- **Mandate**: Refer to \`.ai/assets/progress.md\` at the start of every session.
- **Workflow**: Plan -> Act -> Validate.
- **Handover**: Use \`.ai/assets/session_notes.md\` for session state.
EOF
fi

echo "✅ Project initialized successfully!"
