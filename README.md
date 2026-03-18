# Ralph Starter

A starter template for the **Ralph Method** — an agentic coding workflow where an AI coding agent (Claude Code) runs in a loop, picking up tasks one at a time from a checklist, implementing them, verifying, committing, and moving on.

Named after the [Ralph Wiggum approach](https://ghuntley.com/specs) described by Geoffrey Huntley: keep each agent invocation small, dumb, and focused. Nothing important lives only in the context window — everything goes in markdown files that persist between iterations.

## How It Works

```
┌─────────────┐
│   loop.sh   │  ← bash loop, runs Claude Code repeatedly
└──────┬──────┘
       │
       ▼
┌─────────────────────────┐
│  IMPLEMENTATION_PLAN.md │  ← checklist of tasks: [ ] and [x]
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│    PROMPT_build.md      │  ← instructions for each iteration
└──────┬──────────────────┘
       │
       ▼
┌─────────────────────────┐
│  Claude Code picks ONE  │
│  task, implements it,   │
│  verifies, commits,     │
│  marks [x], exits       │
└──────┬──────────────────┘
       │
       ▼
    loop.sh checks if tasks remain → repeat or stop
```

Each iteration:
1. Claude reads `IMPLEMENTATION_PLAN.md` for the next `[ ]` task
2. Reads specs and `CLAUDE.md` for context
3. Implements the task
4. Verifies it works
5. Commits with `feat(TASK-ID): description`
6. Marks the task `[x]` and exits

The loop continues until all tasks are complete (or all remaining are `BLOCKED:`).

## Quick Start

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A Claude API plan (Max plan recommended for heavy usage)

### 1. Clone this repo

```bash
git clone https://github.com/jakesimonds/ralph-starter.git my-project
cd my-project
```

### 2. Customize the template files

Replace all `{PROJECT_NAME}` and `{PLACEHOLDER}` values:

- **`CLAUDE.md`** — Project description, how to run/test, architecture notes
- **`IMPLEMENTATION_PLAN.md`** — Your actual task breakdown
- **`PROMPT_build.md`** — Add project-specific verification commands
- **`specs/`** — Add feature specs (one markdown file per concern)

### 3. Run the loop

```bash
caffeinate bash loop.sh
```

`caffeinate` prevents your Mac from sleeping. On Linux, use `caffeine` or just `bash loop.sh`.

## File Reference

| File | Purpose |
|---|---|
| `loop.sh` | Bash loop that drives the whole process. Runs Claude Code repeatedly, tracks progress, handles retries and errors. |
| `PROMPT_build.md` | The prompt sent to Claude each iteration. Tells it how to pick a task, implement, verify, and commit. |
| `IMPLEMENTATION_PLAN.md` | Your task checklist. `[ ]` = todo, `[x]` = done, `BLOCKED:` = needs human help. |
| `CLAUDE.md` | Project-level instructions Claude reads every iteration. Put conventions, architecture, and validation commands here. |
| `IMPLEMENTATION_FUTURE.md` | Parking lot for ideas you don't want to commit to yet. |
| `specs/` | Feature specifications. One markdown file per topic. Claude reads these for requirements. |

## Key Principles

- **One task per iteration.** Each Claude invocation does one small thing. This is the core idea.
- **Everything in markdown.** The context window is ephemeral. Specs, plans, and conventions live in files.
- **Verify before committing.** Every task should have a way to check that it works.
- **Small tasks.** If a task feels big, break it into smaller tasks. Each Ralph does a surprisingly small thing.
- **Block, don't guess.** If Claude is stuck, it marks the task `BLOCKED:` and moves on instead of guessing wrong.

## Important: Permissions

The `loop.sh` script runs Claude with `--dangerously-skip-permissions`. This means Claude can read/write files, run commands, and make commits without asking. This is intentional for unattended looping — but understand what it means before running it.

Review the [Claude Code permissions docs](https://docs.anthropic.com/en/docs/claude-code) and make sure you're comfortable with this before running the loop.

## Tips

- **Write good specs.** The better your specs in `specs/`, the better Claude's output. Be specific about behavior, edge cases, and what "done" looks like.
- **Keep CLAUDE.md current.** This is Claude's project bible. Update it as the project evolves.
- **Watch the first few iterations.** Make sure Claude is on the right track before walking away.
- **Use phases.** Group tasks in `IMPLEMENTATION_PLAN.md` by phase. Foundation first, features second, polish last.
- **Dependencies matter.** Use `Depends: TASK-01, TASK-02` lines so Claude doesn't jump ahead.

## Credits

Based on the [Ralph Wiggum method](https://ghuntley.com/specs) by Geoffrey Huntley. Built for use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic.

## License

MIT
