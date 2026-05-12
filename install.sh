#!/usr/bin/env bash

# ==============================================================================
# Blueprint Installation Script
# ==============================================================================
# This script populates an existing project with the Codex/Gemini/Claude Agent
# Blueprint structure (.ai, .agents, .codex, .gemini, .claude, AGENTS.md,
# GEMINI.md, CLAUDE.md).
#
# Usage:
#   ./install.sh                              # installs all services (latest)
#   ./install.sh --version v1.2.0            # installs a specific tagged version
#   ./install.sh --version latest            # explicitly installs latest release
#   ./install.sh --service claude            # installs Claude only
#   ./install.sh --service codex,gemini      # installs Codex + Gemini
#   ./install.sh --service codex --service claude  # same, using repeated flags
# ==============================================================================

set -e

# Configuration
REPO_OWNER="bididi-badidi"
REPO_NAME="agent-project-blueprint"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
TEMP_DIR=$(mktemp -d)
TARGET_DIR=$(pwd)
STAMP_FILE=".ai/assets/.blueprint-version"
REQUEST_VERSION=""
SERVICES=()

# ------------------------------------------------------------------------------
# Argument parsing
# ------------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --version)
            REQUEST_VERSION="$2"
            shift 2
            ;;
        --version=*)
            REQUEST_VERSION="${1#*=}"
            shift
            ;;
        --service)
            IFS=',' read -ra _SVCLIST <<< "$2"
            for _svc in "${_SVCLIST[@]}"; do
                SERVICES+=("$_svc")
            done
            shift 2
            ;;
        --service=*)
            IFS=',' read -ra _SVCLIST <<< "${1#*=}"
            for _svc in "${_SVCLIST[@]}"; do
                SERVICES+=("$_svc")
            done
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [--version <tag|latest>] [--service <name>[,<name>...]]"
            echo ""
            echo "Options:"
            echo "  --version <tag>      Install a specific release tag (e.g. v1.2.0)"
            echo "  --version latest     Install the latest release (default)"
            echo "  --service <name>     Install only the specified service(s)."
            echo "                       Valid values: codex, gemini, claude"
            echo "                       Repeat the flag or use comma-separation for multiple:"
            echo "                         --service codex --service claude"
            echo "                         --service codex,claude"
            echo "                       Omit to install all three (default)."
            echo "  -h, --help           Show this help message"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Run '$0 --help' for usage."
            exit 1
            ;;
    esac
done

# Validate and default services
if [ "${#SERVICES[@]}" -eq 0 ]; then
    SERVICES=("codex" "gemini" "claude")
else
    for _svc in "${SERVICES[@]}"; do
        case "$_svc" in
            codex|gemini|claude) ;;
            *)
                echo "❌ Unknown service: '$_svc'. Valid options: codex, gemini, claude"
                exit 1
                ;;
        esac
    done
fi

# Cleanup on exit
trap "rm -rf '$TEMP_DIR'" EXIT

# ------------------------------------------------------------------------------
# Version resolution
# ------------------------------------------------------------------------------
resolve_version() {
    if [ -z "$REQUEST_VERSION" ] || [ "$REQUEST_VERSION" = "latest" ]; then
        echo "🔍 Fetching latest release..." >&2
        local latest
        latest=$(curl -fsSL \
            "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest" \
            2>/dev/null \
            | grep '"tag_name"' \
            | head -1 \
            | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')
        if [ -n "$latest" ]; then
            echo "$latest"
        else
            echo "⚠️  No releases found, falling back to main branch." >&2
            echo "main"
        fi
    else
        echo "$REQUEST_VERSION"
    fi
}

VERSION=$(resolve_version)

if [ "$VERSION" = "main" ]; then
    SOURCE_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
else
    SOURCE_URL="${REPO_URL}/archive/refs/tags/${VERSION}.tar.gz"
fi

# ------------------------------------------------------------------------------
# Detect existing installation
# ------------------------------------------------------------------------------
INSTALLED_VERSION=""
if [ -f "$TARGET_DIR/$STAMP_FILE" ]; then
    INSTALLED_VERSION=$(cat "$TARGET_DIR/$STAMP_FILE")
fi

IS_UPGRADE=false

if [ -n "$INSTALLED_VERSION" ]; then
    if [ "$INSTALLED_VERSION" = "$VERSION" ]; then
        echo "✅ Blueprint ${VERSION} is already installed."
        read -p "   Reinstall anyway? (y/N): " choice
        if [[ ! "$choice" =~ ^[Yy]$ ]]; then
            echo "Nothing to do."
            exit 0
        fi
    else
        echo "⬆️  Upgrading Blueprint: ${INSTALLED_VERSION} → ${VERSION}"
        IS_UPGRADE=true
    fi
fi

echo "🚀 Starting Blueprint installation (${VERSION})..."

# ------------------------------------------------------------------------------
# Dependency checks
# ------------------------------------------------------------------------------
if ! command -v curl >/dev/null 2>&1; then
    echo "❌ Error: 'curl' is not installed. Please install curl and try again."
    exit 1
fi

if ! command -v tar >/dev/null 2>&1; then
    echo "❌ Error: 'tar' is not installed. Please install tar and try again."
    exit 1
fi

# ------------------------------------------------------------------------------
# Download and extract
# ------------------------------------------------------------------------------
echo "📦 Downloading template from ${SOURCE_URL}..."
if ! curl -fL "$SOURCE_URL" -o "$TEMP_DIR/template.tar.gz" --silent; then
    echo "❌ Error: Failed to download the template."
    if [ "$VERSION" != "main" ]; then
        echo "   Verify that tag '${VERSION}' exists at: ${REPO_URL}/releases"
    else
        echo "   Verify the repository is public at: ${REPO_URL}"
    fi
    exit 1
fi

echo "📂 Extracting files..."
mkdir -p "$TEMP_DIR/extracted"
if ! file "$TEMP_DIR/template.tar.gz" | grep -q "gzip compressed data"; then
    echo "❌ Error: Downloaded file is not a valid archive."
    echo "   This usually means the URL is incorrect or requires authentication."
    exit 1
fi

tar -xz -f "$TEMP_DIR/template.tar.gz" -C "$TEMP_DIR/extracted" --strip-components=1

# ------------------------------------------------------------------------------
# Build list of items to copy based on selected services
# .ai is always included (shared infrastructure)
# ------------------------------------------------------------------------------
ITEMS_TO_COPY=(".ai")
for _svc in "${SERVICES[@]}"; do
    case "$_svc" in
        codex)  ITEMS_TO_COPY+=(".agents" ".codex" "AGENTS.md") ;;
        gemini) ITEMS_TO_COPY+=(".gemini" "GEMINI.md") ;;
        claude) ITEMS_TO_COPY+=(".claude" "CLAUDE.md") ;;
    esac
done

# ------------------------------------------------------------------------------
# Copy blueprint files
# ------------------------------------------------------------------------------
echo "🏗️  Populating project structure (services: ${SERVICES[*]})..."
UPSTREAM_WRITTEN=()

for item in "${ITEMS_TO_COPY[@]}"; do
    src="$TEMP_DIR/extracted/$item"
    dest="$TARGET_DIR/$item"

    if [ ! -e "$src" ]; then
        continue
    fi

    if [ ! -e "$dest" ]; then
        # Item doesn't exist yet — copy directly
        cp -R "$src" "$dest"
        echo "✅ Created $item"

    elif [ "$IS_UPGRADE" = true ]; then
        # Upgrade: write alongside as .upstream so user can diff and merge
        upstream="${dest}.upstream"
        rm -rf "$upstream"
        cp -R "$src" "$upstream"
        UPSTREAM_WRITTEN+=("$item")
        echo "📋 Staged $item → ${item}.upstream"

    else
        # Reinstall: ask before overwriting
        read -p "⚠️  '$item' already exists. Overwrite? (y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            rm -rf "$dest"
            cp -R "$src" "$dest"
            echo "✅ Overwrote $item"
        else
            echo "⏭️  Skipped $item"
        fi
    fi
done

# ------------------------------------------------------------------------------
# Write version stamp
# ------------------------------------------------------------------------------
mkdir -p "$TARGET_DIR/.ai/assets"
echo "$VERSION" > "$TARGET_DIR/$STAMP_FILE"
echo "📌 Version stamp written: $VERSION"

# ------------------------------------------------------------------------------
# Finalizing
# ------------------------------------------------------------------------------
echo ""
echo "✨ Installation complete!"
echo "----------------------------------------------------------------"

if [ "${#UPSTREAM_WRITTEN[@]}" -gt 0 ]; then
    echo "Upgrade notes (${INSTALLED_VERSION} → ${VERSION}):"
    echo "  Upstream files have been written alongside your existing files."
    echo "  Review and merge changes, then delete the .upstream copies:"
    echo ""
    for item in "${UPSTREAM_WRITTEN[@]}"; do
        if [ -d "$TARGET_DIR/$item" ]; then
            echo "    diff -r $item/ ${item}.upstream/"
        else
            echo "    diff $item ${item}.upstream"
        fi
    done
    echo ""
    echo "  When done: rm -rf ${UPSTREAM_WRITTEN[*]/%/.upstream}"
    echo ""
fi

echo "Next steps:"
echo "1. Check '.ai/assets/progress.md' to start tracking your project."

_step=2
for _svc in "${SERVICES[@]}"; do
    case "$_svc" in
        codex)  echo "${_step}. Review 'AGENTS.md' for Codex agent instructions." ;;
        gemini) echo "${_step}. Review 'GEMINI.md' for Gemini agent instructions." ;;
        claude) echo "${_step}. Review 'CLAUDE.md' for Claude agent instructions." ;;
    esac
    (( _step++ )) || true
done

_has_codex=false
for _svc in "${SERVICES[@]}"; do [[ "$_svc" == "codex" ]] && _has_codex=true; done
if [ "$_has_codex" = true ]; then
    echo "${_step}. Trust the project in Codex to enable project-scoped '.codex/config.toml'."
    (( _step++ )) || true
fi

echo "${_step}. Add '.ai/assets/branches/' and '.ai/assets/memory.jsonl' to your .gitignore."
echo "----------------------------------------------------------------"
echo "Happy coding! 🚀"
