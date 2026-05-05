#!/usr/bin/env bash
#
# Fetch and extract official DST Lua scripts into .local-reference-files/
# for reverse-engineering and reference during mod development.
#
# Requires DST_PATH to point to your DST installation root.
# Copy .env.example to .env and set DST_PATH before running.
#
# Usage: ./dev-scripts/fetch-game-scripts.sh

set -euo pipefail

if [ -z "${DST_PATH:-}" ]; then
  echo "Error: DST_PATH is not set. Copy .env.example to .env and set DST_PATH." >&2
  exit 1
fi

if [ ! -d "$DST_PATH" ]; then
  echo "Error: DST_PATH ($DST_PATH) does not exist." >&2
  exit 1
fi

SCRIPTDIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPTDIR/.." && pwd)"
REF_DIR="$PROJECT_ROOT/.local-reference-files"

DATA_DIR="$DST_PATH/data"
SCRIPTS_ZIP="$DATA_DIR/databundles/scripts.zip"
SCRIPTS_README="$DATA_DIR/scripts_readme.txt"

if [ ! -f "$SCRIPTS_ZIP" ]; then
  echo "Error: scripts.zip not found at $SCRIPTS_ZIP" >&2
  exit 1
fi

mkdir -p "$REF_DIR"

cp "$SCRIPTS_ZIP" "$REF_DIR/"
echo "Copied scripts.zip"

if [ -f "$SCRIPTS_README" ]; then
  cp "$SCRIPTS_README" "$REF_DIR/"
  echo "Copied scripts_readme.txt"
fi

mkdir -p "$REF_DIR/game-scripts"
unzip -o "$REF_DIR/scripts.zip" -d "$REF_DIR/game-scripts" > /dev/null
echo "Extracted scripts to .local-reference-files/game-scripts/"

echo "Done."
