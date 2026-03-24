# ralph-optimized

An optimized template for the **Ralph Method** — an agentic coding workflow where Claude Code runs in a loop, picking up tasks one at a time from a checklist, implementing them, verifying, committing, and moving on.

Built on [jakesimonds/ralph-starter](https://github.com/jakesimonds/ralph-starter), which is based on the [Ralph Wiggum approach](https://ghuntley.com/specs) by Geoffrey Huntley.

---

## What's Different From ralph-starter

| Feature | ralph-starter | ralph-optimized |
|---|---|---|
| Permissions | `--dangerously-skip-permissions` | Scoped `--allowedTools` list |
| Rate limiting | None | 30 calls/hour (configurable) |
| Logging | Console only | Persistent `.ralph/run-YYYY-MM-DD.log` |
| Elapsed time | Not shown | Logged per iteration |
| Setup | Manual find/replace | `bash setup.sh "My Project"` |
| Knowledge accumulation | None | `AGENTS.md` — Claude writes discoveries across iterations |
| Secret protection | No `.env` guard | `.env` and `.ralph/` in `.gitignore` |

---

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
2. Reads `AGENTS.md` for accumulated knowledge from prior iterations
3. Reads specs and `CLAUDE.md` for context
4. Implements the task
5. Verifies it works
6. Updates `AGENTS.md` with any new discoveries
7. Commits with `feat(TASK-ID): description`
8. Marks the task `[x]` and exits

The loop continues until all tasks are complete (or all remaining are `BLOCKED:`).

---

## Quick Start

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated
- A Claude API subscription (Max plan recommended for heavy usage)
- `git` installed

### 1. Clone this repo

```bash
git clone https://github.com/Alzxcvb/ralph-optimized.git my-project
cd my-project
```

### 2. Run setup

```bash
bash setup.sh "My Project Name"
```

This replaces all `{PROJECT_NAME}` placeholders, creates the `.ralph/` working directory, and reinitializes git with a clean first commit.

### 3. Customize the template files

- **`CLAUDE.md`** — Add your project description, how to run/test, architecture notes
- **`IMPLEMENTATION_PLAN.md`** — Replace placeholder tasks with your real task breakdown
- **`PROMPT_build.md`** — Add project-specific verification commands
- **`specs/`** — Add feature specs (one markdown file per concern)

### 4. Run the loop

```bash
caffeinate bash loop.sh      # macOS (prevents sleep)
bash loop.sh                 # Linux
```

---

## File Reference

| File | Purpose |
|---|---|
| `loop.sh` | Main loop. Runs Claude Code repeatedly with scoped permissions, rate limiting, and persistent logging. |
| `setup.sh` | One-time setup — replaces placeholders, creates `.ralph/`, initializes git. |
| `PROMPT_build.md` | The prompt sent to Claude each iteration. Tells it how to pick a task, implement, verify, and commit. |
| `IMPLEMENTATION_PLAN.md` | Task checklist. `[ ]` = todo, `[x]` = done, `BLOCKED:` = needs human help. |
| `CLAUDE.md` | Project-level instructions Claude reads every iteration. Put conventions, architecture, and validation commands here. |
| `AGENTS.md` | Accumulated knowledge from prior iterations. Claude appends discoveries here so each loop starts smarter. |
| `IMPLEMENTATION_FUTURE.md` | Parking lot for ideas you don't want to commit to yet. |
| `specs/` | Feature specifications. One markdown file per topic. |
| `.ralph/` | Working directory for logs and rate limit state. Gitignored. |

---

## Configuration

Edit the top of `loop.sh` to tune behavior:

```bash
MAX_ITERATIONS=50          # hard stop after N iterations
MAX_CALLS_PER_HOUR=30      # rate limit — increase if you want to go faster
MAX_CONSECUTIVE_ERRORS=3   # stop after N consecutive Claude failures
ERROR_COOLDOWN=60          # seconds to wait after a failure

# Add/remove tools to match your project's needs
ALLOWED_TOOLS="Write,Read,Edit,MultiEdit,Bash(git add *),Bash(git commit *),..."
```

---

## Permissions Model

This template uses `--allowedTools` instead of `--dangerously-skip-permissions`.

Claude gets access to exactly the tools listed in `ALLOWED_TOOLS` — file read/write/edit, specific git commands, npm, python, pytest. Destructive commands (`git reset --hard`, `git clean`, `rm -rf`) are not in the list and will be blocked.

If Claude gets stuck because it needs a tool that isn't listed, add it to `ALLOWED_TOOLS`. You're in control of the surface area.

---

## Key Principles

- **One task per iteration.** Each Claude invocation does one small thing.
- **Everything in markdown.** The context window is ephemeral. Specs, plans, and conventions live in files.
- **Verify before committing.** Every task should have a way to check that it works.
- **Small tasks.** If a task feels big, break it into smaller tasks.
- **Block, don't guess.** If Claude is stuck, it marks the task `BLOCKED:` and moves on.
- **Knowledge accumulates.** Claude writes what it learns to `AGENTS.md` so the next iteration starts smarter.

---

## Tips

- **Write good specs.** The better your specs in `specs/`, the better Claude's output.
- **Keep CLAUDE.md current.** This is Claude's project bible. Update it as the project evolves.
- **Watch the first few iterations.** Make sure Claude is on the right track before walking away.
- **Use phases.** Group tasks in `IMPLEMENTATION_PLAN.md` by phase. Foundation first, features second, polish last.
- **Dependencies matter.** Use `Depends: TASK-01, TASK-02` lines so Claude doesn't jump ahead.
- **Check the log.** After an overnight run, review `.ralph/run-YYYY-MM-DD.log` to see what happened.

---

## Credits

Based on [ralph-starter](https://github.com/jakesimonds/ralph-starter) by jakesimonds, which is based on the [Ralph Wiggum method](https://ghuntley.com/specs) by Geoffrey Huntley. Built for use with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) by Anthropic.

## License

MIT
