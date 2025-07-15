#!/bin/bash

# Usage: ./release_with_cutoff.sh "<commit-message>" <tag-name> <cutoff-date> [release-notes-file]
# Example: ./release_with_cutoff.sh "Add login flow" v1.2.0 2024-01-01

COMMIT_MSG="$1"
TAG_NAME="$2"
CUTOFF_DATE="$3"
RELEASE_NOTES_FILE="$4"

# Validate input
if [[ -z "$COMMIT_MSG" || -z "$TAG_NAME" || -z "$CUTOFF_DATE" ]]; then
  echo "❌ Usage: $0 \"<commit-message>\" <tag-name> <cutoff-date> [release-notes-file]"
  exit 1
fi

# Ensure we're in a Git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Not a Git repository."
  exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "📍 Current branch: $CURRENT_BRANCH"

# Show latest commit after cutoff
echo "🔍 Latest commit after $CUTOFF_DATE:"
git log --since="$CUTOFF_DATE" -1 --oneline || echo "⚠️  No commits after cutoff."

# Stage and commit changes
git add .
git commit -m "$COMMIT_MSG"

# Push to remote
git push origin "$CURRENT_BRANCH"

# Generate release notes
if [ -n "$RELEASE_NOTES_FILE" ] && [ -f "$RELEASE_NOTES_FILE" ]; then
  RELEASE_NOTES=$(cat "$RELEASE_NOTES_FILE")
else
  echo "📝 Generating release notes from commits since $CUTOFF_DATE..."
  RELEASE_NOTES=$(git log --since="$CUTOFF_DATE" --pretty=format:"- %s (%an)" --reverse)

  if [ -z "$RELEASE_NOTES" ]; then
    echo "⚠️  No commits found after cutoff. Aborting tag creation."
    exit 1
  fi
fi

# Create annotated tag
git tag -a "$TAG_NAME" -m "$RELEASE_NOTES"

# Push the tag
git push origin "$TAG_NAME"

# Confirmation
echo ""
echo "✅ Changes committed and pushed to '$CURRENT_BRANCH'"
echo "🏷️  Tag '$TAG_NAME' created and pushed with release notes:"
echo "-----------------------------"
echo "$RELEASE_NOTES"
echo "-----------------------------"

