#!/usr/bin/env bash
set -e

HOOK_DIR=".git/hooks"
HOOK_FILE="$HOOK_DIR/pre-commit"

cp hook.sh "$HOOK_FILE"
chmod +x "$HOOK_FILE"

cp patterns.json ".secret-guard-patterns.json"

echo "✅ Secret Guard installed!"
echo "🔒 Commits will now be scanned for secrets"
