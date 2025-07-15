#!/bin/bash

# Set cutoff date (YYYY-MM-DD format)
CUTOFF_DATE="2025-07-01"

# Check if inside a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "❌ Not a git repository. Please run this inside a Git repo."
  exit 1
fi

echo "🔍 Checking commits and tags since: $CUTOFF_DATE"

# Get latest commit after cutoff
latest_commit=$(git log --since="$CUTOFF_DATE" -1 --pretty=format:"%h - %s (%an, %ad)" --date=short)

# Check if a commit was found
if [ -z "$latest_commit" ]; then
  echo "⚠️  No commits found after $CUTOFF_DATE."
else
  echo ""
  echo "✅ Latest Commit after $CUTOFF_DATE:"
  echo "$latest_commit"
fi

# Get latest tag (by tag creation date) after cutoff
latest_tag=$(git for-each-ref --sort=-creatordate --format '%(refname:short) %(creatordate:short)' refs/tags | \
  awk -v cutoff="$CUTOFF_DATE" '$2 >= cutoff { print $1; exit }')

if [ -n "$latest_tag" ]; then
  tag_commit=$(git rev-list -n 1 "$latest_tag")
  tag_commit_info=$(git show -s --format="%h - %s (%an, %ad)" "$tag_commit" --date=short)

  echo ""
  echo "🏷️  Latest Tag after $CUTOFF_DATE: $latest_tag"
  echo "$tag_commit_info"
else
  echo ""
  echo "⚠️  No tags found after $CUTOFF_DATE."
fi

