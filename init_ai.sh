#!/bin/bash

# Define the base directories
ASSETS_DIR=".ai/assets"
PHASES_DIR="$ASSETS_DIR/phases"
BRANCHES_DIR="$ASSETS_DIR/branches"
EXAMPLES_DIR="$ASSETS_DIR/examples"
SCRIPTS_DIR=".ai/scripts"

echo "🚀 Initializing .ai directory structure..."

# 1. Create Directories
mkdir -p "$PHASES_DIR" "$BRANCHES_DIR" "$EXAMPLES_DIR" "$SCRIPTS_DIR"

# 2. Create Boilerplate Files (only if they don't exist)

# progress.md
if [ ! -f "$ASSETS_DIR/progress.md" ]; then
cat <<EOF > "$ASSETS_DIR/progress.md"
# Project Progress

## Current Task

- [ ] Project Setup & Initialization

## Upcoming

- Phase 1: Research & Setup

## Project Documents

- [Architecture & Plan](.ai/assets/PLAN.md)
- [Session Notes](.ai/assets/session_notes.md)
- [Backlog](.ai/assets/backlog.md)
- [Task Archive](.ai/assets/task_archive.md)

## Phases

### [ ] [Phase 1: Research & Setup](.ai/assets/phases/phase1_research_setup.md)
EOF
fi

# PLAN.md
if [ ! -f "$ASSETS_DIR/PLAN.md" ]; then
cat <<EOF > "$ASSETS_DIR/PLAN.md"
# Project Plan

## Overview
A brief description of the project goals.

## System Architecture
Describe the high-level components here.
EOF
fi

# backlog.md
[ ! -f "$ASSETS_DIR/backlog.md" ] && echo "# Project Backlog" > "$ASSETS_DIR/backlog.md"

# task_archive.md
[ ! -f "$ASSETS_DIR/task_archive.md" ] && echo "# Task Archive" > "$ASSETS_DIR/task_archive.md"

# memory.jsonl (empty file)
touch "$ASSETS_DIR/memory.jsonl"

# examples/session_notes.md
if [ ! -f "$EXAMPLES_DIR/session_notes.md" ]; then
cat <<EOF > "$EXAMPLES_DIR/session_notes.md"
# Session Handover Notes

**Target:** Reviewer Agent or Next Coder Agent

## ⚠️ Fragile Code / Watch Out
- Notes on race conditions or fragile logic.

## 🧠 Context / Technical Decisions
- Why certain patterns were chosen.

## ⏭️ Next Steps / Blockers
- What to do in the next session.
EOF
fi

# session_notes.md (the active scratchpad)
[ ! -f "$ASSETS_DIR/session_notes.md" ] && cp "$EXAMPLES_DIR/session_notes.md" "$ASSETS_DIR/session_notes.md"

# GEMINI.md (Rules for the agent)
if [ ! -f "GEMINI.md" ]; then
cat <<EOF > "GEMINI.md"
# Local Coder Agent

You are a project-aware coding agent. You read real codebase, reasons across multiple files, and takes concrete action.

---

## 0. Project Progress Tracking (Mandatory)
You MUST refer to the \`PLAN.md\` and \`progress.md\` file in the \`.ai/assets/\` directory at the start of every session.

- **Update Frequency:** Update \`progress.md\` after every significant milestone.
- **Session Notes:** Use \`.ai/assets/session_notes.md\` as a persistent scratchpad.

---

## 0.1 Strict Rules for Managing progress.md
1. **The Active Limit:** Max 5 active items in "Current Task".
2. **Aggressive Archiving:** Move completed tasks (\`[x]\`) to \`.ai/assets/task_archive.md\`.
3. **Backlog Delegation:** New features go to \`.ai/assets/backlog.md\`.

---

## 0.2 The Handover Protocol (Session Notes)
1. **No Changelogs:** Use git for history.
2. **Context Only:** Explain *why* you did something or flag fragile code.
3. **Reset:** Always delete the previous agent's notes before starting.
EOF
fi

echo "✅ .ai folder and assets generated successfully!"
echo "💡 Reminder: Add '.ai/assets/branches/' and '.ai/assets/memory.jsonl' to your .gitignore if you want to keep them local."
