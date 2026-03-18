#!/bin/bash

# Ralph Loop — {PROJECT_NAME}
# Runs Claude Code in a loop until all tasks are complete
# Usage: caffeinate bash loop.sh

set +e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLAN_FILE="$PROJECT_DIR/IMPLEMENTATION_PLAN.md"
MAX_ITERATIONS=50
ITERATION=0
CONSECUTIVE_ERRORS=0
MAX_CONSECUTIVE_ERRORS=3
ERROR_COOLDOWN=60

echo "Starting Ralph Loop: {PROJECT_NAME}"
echo "   Project: $PROJECT_DIR"
echo "   Max iterations: $MAX_ITERATIONS"
echo ""

# Main build loop
while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ITERATION=$((ITERATION + 1))
    echo "================================================================"
    echo "Iteration $ITERATION of $MAX_ITERATIONS"
    echo "================================================================"

    # Check if all tasks are complete
    if [ -f "$PLAN_FILE" ]; then
        INCOMPLETE=$(grep -c "^- \[ \]" "$PLAN_FILE" 2>/dev/null | tr -cd '0-9' || echo "0")
        INCOMPLETE=${INCOMPLETE:-0}
        COMPLETE=$(grep -c "^- \[x\]" "$PLAN_FILE" 2>/dev/null | tr -cd '0-9' || echo "0")
        COMPLETE=${COMPLETE:-0}
        BLOCKED=$(grep -c "BLOCKED:" "$PLAN_FILE" 2>/dev/null | tr -cd '0-9' || echo "0")
        BLOCKED=${BLOCKED:-0}

        echo "Status: $COMPLETE complete, $INCOMPLETE remaining, $BLOCKED blocked"
        echo ""

        if [ "$INCOMPLETE" -eq 0 ] 2>/dev/null; then
            echo "All tasks complete!"
            echo "  Total iterations: $ITERATION"
            echo "  Tasks completed: $COMPLETE"
            exit 0
        fi

        if [ "$BLOCKED" -gt 0 ] 2>/dev/null && [ "$INCOMPLETE" -eq "$BLOCKED" ] 2>/dev/null; then
            echo "All remaining tasks are blocked. Human intervention needed."
            grep "BLOCKED:" "$PLAN_FILE"
            exit 1
        fi
    fi

    # Run build mode
    echo "Running build mode..."
    cd "$PROJECT_DIR"

    TEMP_OUTPUT=$(mktemp)
    trap "rm -f $TEMP_OUTPUT" EXIT

    RETRY=0
    MAX_RETRIES=3
    EXIT_CODE=1
    while [ $RETRY -lt $MAX_RETRIES ]; do
        claude -p --verbose --output-format stream-json --dangerously-skip-permissions \
            "Read PROMPT_build.md and follow its instructions. Pick the next incomplete task from IMPLEMENTATION_PLAN.md, implement it, verify it works, commit, and mark it complete." 2>&1 | \
            while IFS= read -r line; do
                echo "$line" >> "$TEMP_OUTPUT"
                if echo "$line" | grep -q '"type":"tool_use"'; then
                    TOOL=$(echo "$line" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')
                    FILEPATH=$(echo "$line" | sed -n 's/.*"file_path":"\([^"]*\)".*/\1/p' | sed 's|.*/||')
                    CMD=$(echo "$line" | sed -n 's/.*"command":"\([^"]*\)".*/\1/p' | head -c 40)
                    if [ -n "$TOOL" ]; then
                        if [ -n "$FILEPATH" ]; then
                            echo "  > $TOOL: $FILEPATH"
                        elif [ -n "$CMD" ]; then
                            echo "  > $TOOL: $CMD..."
                        else
                            echo "  > $TOOL"
                        fi
                    fi
                elif echo "$line" | grep -q '"type":"result"'; then
                    if echo "$line" | grep -q '"is_error":false'; then
                        echo "  Task complete"
                    else
                        echo "  Task failed"
                    fi
                fi
            done
        EXIT_CODE=${PIPESTATUS[0]}

        OUTPUT=$(cat "$TEMP_OUTPUT")

        if echo "$OUTPUT" | grep -q "No messages returned"; then
            echo "Claude Code API error (No messages returned) - recoverable"
            EXIT_CODE=1
        fi

        if [ $EXIT_CODE -eq 0 ]; then
            CONSECUTIVE_ERRORS=0
            break
        fi

        RETRY=$((RETRY + 1))
        if [ $RETRY -lt $MAX_RETRIES ]; then
            echo "Claude failed (exit $EXIT_CODE), retry $RETRY of $MAX_RETRIES in 10s..."
            sleep 10
        fi
    done

    if [ $EXIT_CODE -ne 0 ]; then
        CONSECUTIVE_ERRORS=$((CONSECUTIVE_ERRORS + 1))
        echo "Claude exited with code $EXIT_CODE (consecutive errors: $CONSECUTIVE_ERRORS/$MAX_CONSECUTIVE_ERRORS)"

        if [ $CONSECUTIVE_ERRORS -ge $MAX_CONSECUTIVE_ERRORS ]; then
            echo "Too many consecutive errors. Stopping for human review."
            exit 1
        fi

        echo "Cooling down for $ERROR_COOLDOWN seconds..."
        sleep $ERROR_COOLDOWN
    else
        echo "Sleeping 15 seconds before next iteration..."
        sleep 15
    fi
done

echo "Max iterations ($MAX_ITERATIONS) reached."
exit 1
