#!/usr/bin/env bash
set -euo pipefail

REPO="dawksh/leaklint"
VERSION="latest"

echo "🔍 Installing leaklint $VERSION..."

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "❌ Not inside a git repository"
  exit 1
fi

HOOK_DIR=".git/hooks"
mkdir -p "$HOOK_DIR"

curl -fsSL \
  "https://github.com/$REPO/releases/download/$VERSION/hook.sh" \
  -o "$HOOK_DIR/pre-commit"

chmod +x "$HOOK_DIR/pre-commit"

curl -fsSL \
  "https://github.com/$REPO/releases/download/$VERSION/patterns.json" \
  -o ".leaklint-patterns.json"

echo "✅ leaklint installed"
