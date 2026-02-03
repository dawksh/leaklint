#!/usr/bin/env bash
set -e

ROOT_DIR=$(git rev-parse --show-toplevel)
PATTERNS_FILE="$ROOT_DIR/.secret-guard-patterns.json"

if [ ! -f "$PATTERNS_FILE" ]; then
  echo "❌ Secret patterns file not found: $PATTERNS_FILE"
  exit 1
fi

STAGED_DIFF=$(git diff --cached -U0)

FOUND=0

while IFS= read -r line; do
  NAME=$(echo "$line" | jq -r 'keys[]')
  REGEX=$(echo "$line" | jq -r '.[keys[]]')
done < <(jq -c 'to_entries[] | {(.key): .value}' "$PATTERNS_FILE")

mapfile -t diff_lines <<<"$STAGED_DIFF"

for i in "${!diff_lines[@]}"; do
  diff_line="${diff_lines[$i]}"
  [[ "$diff_line" =~ ^\+[^+] ]] || continue

  for key in $(jq -r 'keys[]' "$PATTERNS_FILE"); do
    regex=$(jq -r --arg k "$key" '.[$k]' "$PATTERNS_FILE")

    if echo "$diff_line" | grep -Eqi "$regex"; then
      next_line="${diff_lines[$((i+1))]}"
      
      if echo "$diff_line" | grep -qi "//allow-leaky" || echo "$next_line" | grep -qi "//allow-leaky"; then
        continue
      fi
      
      echo "🚨 SECRET DETECTED: $key"
      echo "→ $diff_line"
      FOUND=1
    fi
  done
done

if [ "$FOUND" -eq 1 ]; then
  echo ""
  echo "❌ Commit blocked. Remove secrets before committing."
  echo "💡 Tip: use env vars or .env files"
  exit 1
fi

exit 0
