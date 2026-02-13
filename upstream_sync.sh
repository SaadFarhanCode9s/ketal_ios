#!/bin/bash

# Upstream Sync Script for Ketal iOS
# Syncs changes from element-x-ios upstream while preserving Ketal customizations.

set -e

UPSTREAM_URL="https://github.com/element-hq/element-x-ios.git"
UPSTREAM_REMOTE="upstream"
UPSTREAM_BRANCH="main"

echo "----------------------------------------------------------------"
echo "🔄 Starting Upstream Sync for Ketal iOS"
echo "----------------------------------------------------------------"

# 1. Ensure upstream remote exists
if ! git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    echo "Adding upstream remote: $UPSTREAM_URL"
    git remote add $UPSTREAM_REMOTE $UPSTREAM_URL
else
    echo "Upstream remote '$UPSTREAM_REMOTE' already exists."
fi

# 2. Fetch upstream
echo "Fetching from $UPSTREAM_REMOTE..."
git fetch $UPSTREAM_REMOTE

# 3. Merge upstream changes
# We use --no-commit to allow inspection before finalizing if needed, 
# but usually we want to commit if clean.
# 'merge=ours' attributes in .gitattributes should protect config files.

echo "Merging $UPSTREAM_REMOTE/$UPSTREAM_BRANCH..."
if git merge $UPSTREAM_REMOTE/$UPSTREAM_BRANCH; then
    echo "✅ Merge successful."
else
    echo "⚠️ Merge conflicts detected."
    echo "Please resolve conflicts manually."
    echo "Protected files (ketal_config.yml, project.yml, etc.) should have been handled by .gitattributes (ours/union)."
    echo "Check status with 'git status'."
    exit 1
fi

# 4. Re-apply Ketal Configuration
echo "Applying Ketal Configuration..."
if [ -f "./apply_ketal_config.sh" ]; then
    ./apply_ketal_config.sh
else
    echo "❌ Error: apply_ketal_config.sh not found!"
    exit 1
fi

echo "----------------------------------------------------------------"
echo "✅ Upstream Sync Complete"
echo "----------------------------------------------------------------"
echo "Next steps:"
echo "1. Run 'swift run tools setup-project' to regenerate the Xcode project."
echo "2. Build and Test."
