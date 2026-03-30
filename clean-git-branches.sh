#!/bin/bash

# ================================================================
# Git Repo Update & Branch Cleanup Tool
# Author: Tux1991
# ================================================================
# Usage: ./update-and-clean-branches.sh /path/to/projects
#  
# Workflow:
#   1. Switch to main branch and pull the latest version in all repos
#   2. Delete all non-main branches after confirmation
# ================================================================

# --- 1. Validate input ---
if [ -z "$1" ]; then
  echo "❌ Please provide the path to your projects folder."
  echo "👉 Example: ./update-and-clean-branches.sh ~/projects"
  exit 1
fi

PROJECTS_PATH="$1"

if [ ! -d "$PROJECTS_PATH" ]; then
  echo "❌ Path not found: $PROJECTS_PATH"
  exit 1
fi

echo "🧹 Searching for git repositories under: $PROJECTS_PATH"
echo

# --- 2. Find all repositories ---
REPOS=$(find "$PROJECTS_PATH" -type d -name ".git" | sed 's/\/.git$//')

# --- 3. Pass 1: Update all repos ---
echo "⬇️  Updating all repositories (switching to main and pulling latest)..."
for REPO_DIR in $REPOS; do
  echo "🔧 Processing repo: $REPO_DIR"
  cd "$REPO_DIR" || continue

  git checkout main 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "⚠️  Could not checkout 'main'. Skipping..."
    echo
    continue
  fi

  git pull origin main
  echo "✅ Updated $REPO_DIR"
  echo
done

# --- 4. Pass 2: Delete non-main branches with confirmation ---
echo
echo "🗑️  Checking for non-main branches to delete..."
for REPO_DIR in $REPOS; do
  echo "🔧 Processing repo: $REPO_DIR"
  cd "$REPO_DIR" || continue

  branches=$(git branch | grep -v "main")
  if [ -z "$branches" ]; then
    echo "✅ No extra branches found."
    echo
    continue
  fi

  echo "📋 The following branches will be deleted in $REPO_DIR:"
  echo "$branches"
  echo

  read -rp "❓ Do you really want to delete ALL these branches (except main)? [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "$branches" | xargs git branch -D
    git fetch --prune
    echo "✅ Deleted all non-main branches in $REPO_DIR."
  else
    echo "🚫 Skipped deleting branches."
  fi

  echo "------------------------------------"
  echo
done

echo "🎉 Done updating and cleaning all repositories under: $PROJECTS_PATH"

