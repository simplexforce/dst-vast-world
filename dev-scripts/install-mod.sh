#!/usr/bin/env bash
#
# Install dst-vast-world into the DST mods directory for testing.
# Copies the mod files (not docs, not local references) into
# $DST_PATH/mods/dst-vast-world/.
#
# Requires DST_PATH to point to your DST installation root.
# Copy .env.example to .env and set DST_PATH before running.
#
# Usage: ./dev-scripts/install-mod.sh

set -euo pipefail

if [ -z "${DST_PATH:-}" ]; then
  echo "Error: DST_PATH is not set. Copy .env.example to .env and set DST_PATH." >&2
  exit 1
fi

if [ ! -d "$DST_PATH" ]; then
  echo "Error: DST_PATH ($DST_PATH) does not exist." >&2
  exit 1
fi

MODS_DIR="$DST_PATH/mods"

if [ ! -d "$MODS_DIR" ]; then
  echo "Error: mods directory not found at $MODS_DIR" >&2
  exit 1
fi

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPTDIR/.." && pwd)"
TARGET="$MODS_DIR/dst-vast-world"

# Files and directories to include in the installed mod
MOD_FILES=(
  modinfo.lua
  modmain.lua
  modworldgenmain.lua
  scripts/
)

# Remove previous installation
if [ -d "$TARGET" ]; then
  rm -rf "$TARGET"
  echo "Removed previous installation"
fi

mkdir -p "$TARGET"

for item in "${MOD_FILES[@]}"; do
  src="$PROJECT_ROOT/$item"
  if [ -e "$src" ]; then
    cp -r "$src" "$TARGET/"
  fi
done

echo "Installed to $TARGET"
