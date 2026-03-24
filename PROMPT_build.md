# Build Mode Prompt

You are in BUILD MODE for {PROJECT_NAME}.

## Your Task
Pick ONE task from `IMPLEMENTATION_PLAN.md`, implement it, verify it works, and mark it complete.

## Process

1. **Read IMPLEMENTATION_PLAN.md** to find the next incomplete task
2. **Read relevant specs** in `specs/` for requirements
3. **Read CLAUDE.md** for project conventions
4. **Read AGENTS.md** for discovered commands, gotchas, and patterns from prior iterations
5. **Implement the task** — edit or create files as needed
6. **Verify** — run tests, syntax checks, or whatever validation the task requires
7. **Update IMPLEMENTATION_PLAN.md** — change `[ ]` to `[x]`
8. **Update AGENTS.md** — append any new commands, gotchas, or patterns discovered this session
9. **Commit** all changes with message format: `feat(TASK-ID): description`
10. **Exit** so the next iteration starts fresh

## Task Selection Rules

Pick the FIRST incomplete task that:
- Has all dependencies completed (check `Depends:` lines)
- Is marked with `[ ]` (not `[x]`)

## Key Principles

- One task per session. Do NOT implement multiple tasks.
- Verify before committing. ALL checks must pass.
- If stuck, mark as `BLOCKED:` with clear description and move to next task.
- No TODO comments. If functionality is missing, add it now.
- Keep it simple. Vanilla JS, no unnecessary frameworks or dependencies.

## Verification

{CUSTOMIZE: Add project-specific verification commands here}

```bash
# Example:
# node --check src/index.js
# npm test
```

## If Stuck

1. Document the blocker in IMPLEMENTATION_PLAN.md
2. Add `BLOCKED:` prefix to the task
3. Move to the next available task
4. Only exit for human review if ALL remaining tasks are blocked

## Spec-Code Discrepancy Protocol

If code behaves differently from specs and fixing it would change user-visible behavior:
1. DO NOT silently fix it
2. Mark as `BLOCKED:` with clear description
3. Exit immediately for human review

## Do NOT

- Implement multiple tasks in one session
- Skip verification steps
- Leave TODO comments
- Break existing functionality
