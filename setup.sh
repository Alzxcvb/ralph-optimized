#!/bin/bash

# setup.sh — Initialize a new Ralph project from this template
# Usage: bash setup.sh "My Project Name"
#
# This script:
#   1. Replaces {PROJECT_NAME} placeholders across all template files
#   2. Creates the .ralph/ working directory
#   3. Reinitializes git with a clean first commit

set -e

if [ -z "$1" ]; then
    echo "Usage: bash setup.sh \"My Project Name\""
    echo ""
    echo "Example:"
    echo "  bash setup.sh \"Richard Trading Bot\""
    exit 1
fi

PROJECT_NAME="$1"

echo "Setting up Ralph project: $PROJECT_NAME"
echo ""

# Replace {PROJECT_NAME} in all template files
for file in CLAUDE.md IMPLEMENTATION_PLAN.md IMPLEMENTATION_FUTURE.md PROMPT_build.md loop.sh; do
    if [ -f "$file" ]; then
        sed -i.bak "s/{PROJECT_NAME}/$PROJECT_NAME/g" "$file"
        rm -f "${file}.bak"
        echo "  Updated $file"
    fi
done

# Create .ralph working directory (logs, rate limit state)
mkdir -p .ralph
echo "  Created .ralph/"

# Reinitialize git with a clean first commit
if [ -d .git ]; then
    rm -rf .git
    git init -q
    git add -A
    git commit -q -m "init: $PROJECT_NAME (Ralph template)"
    echo "  Fresh git repo initialized"
fi

echo ""
echo "Done. Next steps:"
echo "  1. Edit CLAUDE.md       — add architecture, how to run/test"
echo "  2. Edit IMPLEMENTATION_PLAN.md — replace placeholder tasks with real ones"
echo "  3. Edit PROMPT_build.md — add project-specific verification commands"
echo "  4. Add specs to specs/  — one markdown file per feature"
echo "  5. Run: caffeinate bash loop.sh"
