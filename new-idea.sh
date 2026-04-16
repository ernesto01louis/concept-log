#!/usr/bin/env bash
set -euo pipefail

# new-idea.sh — Create a new concept entry from the template
# Run from the concept-log repo root.
#
# Usage:
#   ./new-idea.sh "gpu-cluster-aero-optimization"
#
# This creates the file, fills in today's date, and commits it.
# The commit timestamp is your proof-of-date.

if [ -z "${1:-}" ]; then
  echo "Usage: ./new-idea.sh <idea-slug>"
  echo "Example: ./new-idea.sh gpu-cluster-aero-optimization"
  exit 1
fi

SLUG="$1"
DATE=$(date +%Y-%m-%d)
FILE="ideas/${SLUG}.md"

if [ -f "$FILE" ]; then
  echo "Error: $FILE already exists."
  exit 1
fi

cp TEMPLATE.md "$FILE"
sed -i "s/YYYY-MM-DD/$DATE/" "$FILE"
sed -i "s/{Concept Title}/$SLUG/" "$FILE"

git add "$FILE"
git commit -m "Log concept: $SLUG"

echo "Created $FILE (dated $DATE)"
echo "Edit the file to fill in the details, then amend or push:"
echo "  git push origin main"
