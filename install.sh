#!/bin/bash

# ==============================================================================
# Blueprint Installation Script
# ==============================================================================
# This script populates an existing project with the Gemini/Claude Agent 
# Blueprint structure (.ai, .gemini, .claude, GEMINI.md, CLAUDE.md).
# ==============================================================================

set -e

# Configuration
REPO_URL="https://github.com/bididi-badidi/agent-project-blueprint"
SOURCE_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
TEMP_DIR=$(mktemp -d)
TARGET_DIR=$(pwd)

# Cleanup on exit
trap "rm -rf '$TEMP_DIR'" EXIT

echo "🚀 Starting Blueprint installation..."

# 1. Dependency Checks
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ Error: 'curl' is not installed. Please install curl and try again."
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "❌ Error: 'tar' is not installed. Please install tar and try again."
    exit 1
fi

# 2. Download and Extract
echo "📦 Downloading template from ${REPO_URL}..."
# Use -f to fail on HTTP errors and -L to follow redirects
if ! curl -fL "$SOURCE_URL" -o "$TEMP_DIR/template.tar.gz" --silent; then
    echo "❌ Error: Failed to download the template."
    echo "   Please verify that the repository exists and the 'main' branch is public."
    echo "   URL: $SOURCE_URL"
    exit 1
fi

echo "📂 Extracting files..."
mkdir -p "$TEMP_DIR/extracted"
# Check if the file is actually a gzip file before extracting
if ! file "$TEMP_DIR/template.tar.gz" | grep -q "gzip compressed data"; then
    echo "❌ Error: Downloaded file is not a valid archive. This usually happens if the URL is incorrect or requires authentication."
    exit 1
fi

tar -xz -f "$TEMP_DIR/template.tar.gz" -C "$TEMP_DIR/extracted" --strip-components=1

# 3. Copy Blueprint Files
echo "🏗️  Populating project structure..."

# List of items to copy
ITEMS_TO_COPY=(".ai" ".gemini" ".claude" "GEMINI.md" "CLAUDE.md")

for item in "${ITEMS_TO_COPY[@]}"; do
    if [ -e "$TEMP_DIR/extracted/$item" ]; then
        if [ -e "$TARGET_DIR/$item" ]; then
            read -p "⚠️  '$item' already exists. Overwrite? (y/N): " choice
            if [[ "$choice" =~ ^[Yy]$ ]]; then
                rm -rf "$TARGET_DIR/$item"
                cp -R "$TEMP_DIR/extracted/$item" "$TARGET_DIR/$item"
                echo "✅ Overwrote $item"
            else
                echo "⏭️  Skipped $item"
            fi
        else
            cp -R "$TEMP_DIR/extracted/$item" "$TARGET_DIR/$item"
            echo "✅ Created $item"
        fi
    fi
done

# 4. Finalizing
echo ""
echo "✨ Installation complete!"
echo "----------------------------------------------------------------"
echo "Next steps:"
echo "1. Review 'GEMINI.md' and 'CLAUDE.md' for agent instructions."
echo "2. Check '.ai/assets/progress.md' to start tracking your project."
echo "3. Add '.ai/assets/branches/' and '.ai/assets/memory.jsonl' to your .gitignore."
echo "----------------------------------------------------------------"
echo "Happy coding! 🚀"
