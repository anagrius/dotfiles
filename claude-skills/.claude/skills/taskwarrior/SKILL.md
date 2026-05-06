---
name: taskwarrior
description: Manage tasks and plan the day using Taskwarrior (the `task` CLI). Use this skill whenever the user mentions tasks, todos, planning their day, what to work on, due dates, task priorities, completing tasks, or asks to add/list/modify/done tasks. Also trigger when the user says "plan my day", "what's on my plate", "what should I do today", "td", or references Taskwarrior, task projects, or task priorities. Even if the user just casually mentions needing to do something ("I need to remember to X", "remind me to Y", "add X to my list"), use this skill to capture it.
---

# Taskwarrior Skill

Manage tasks and plan the day using the `task` CLI (Taskwarrior v3). The user has three projects: **Personal**, **Rental**, and **Berserk**. Default project is Personal.

## Quick reference

### Reading tasks

```bash
# All pending tasks
task list

# Tasks for a specific project
task project:Rental list

# Tasks due today
task due:today list

# Overdue tasks
task overdue

# Most urgent tasks (sorted by urgency score)
task next

# Full detail on a specific task
task <ID> information

# Export as JSON (useful for programmatic access)
task export
```

### Adding tasks

```bash
# Simple (goes to Personal by default)
task add "Buy groceries"

# With project
task add project:Rental "Fix leaky faucet"

# With priority (H=high, M=medium, L=low)
task add priority:H "Urgent thing"

# With due date
task add due:friday "Weekly report"
task add due:2026-04-20 "Tax deadline"

# With tags
task add +phone "Call electrician"

# Recurring
task add recur:weekly due:monday "Weekly standup prep"

# Scheduled (hidden until date, then appears)
task add scheduled:2026-04-20 "Start tax filing"
```

### Modifying tasks

```bash
# Change due date to end of today (23:59:59 — see note below)
task <ID> modify due:eod

# Set multiple tasks due today at once
task <ID1> <ID2> <ID3> modify due:eod rc.confirmation=off

# Add a tag
task <ID> modify +urgent

# Change project
task <ID> modify project:Rental

# Add an annotation (note)
task <ID> annotate "Spoke with contractor, will come Thursday"
```

### Completing and removing

```bash
# Mark done
task <ID> done

# Delete (removes, can undo)
task <ID> delete rc.confirmation=off

# Undo last change
task undo
```

### Useful filters

```bash
# By tag
task +phone list

# By priority
task priority:H list

# Overdue
task overdue

# Due this week
task due.before:eow list

# Due this month
task due.before:eom list

# Combination
task project:Rental priority:H list
```

## Day planning workflow

This is the core interactive workflow. When the user asks to plan their day (or similar), follow this process:

### Step 0: Email triage (once per day)

Before looking at tasks, check Gmail for anything that might need action. Run the bundled triage script:

```bash
bash ~/.claude/skills/taskwarrior/scripts/email-triage.sh
```

The script automatically skips if it already ran today. Use `--force` to re-run.

It fetches unread emails from the last 3 days (excluding promotions/social) and starred threads from the last 7 days. Review the output and look for actionable items — things like:
- Emails that need a reply or follow-up
- Bills, renewals, or deadlines mentioned
- Meeting requests or scheduling needs
- Anything the user should be aware of

If you spot potential tasks, note them and propose them alongside the existing task list in Step 2. Don't create tasks yet — present them as suggestions first.

If the email triage needs deeper inspection (e.g., you want to read a full email body), use gog directly:

```bash
gog gmail get <messageId>
```

### Step 1: Gather task context

Run these to understand the current state:

```bash
task due:today list 2>&1        # Already planned for today
task overdue 2>&1               # Overdue items that need attention
task next 2>&1                  # All tasks sorted by urgency
task projects 2>&1              # Project breakdown
```

Note: Taskwarrior returns exit code 1 when a filter matches zero tasks ("No matches."). This is normal — use `2>&1` and don't chain with `&&` to avoid breaking on empty results.

### Step 2: Propose a daily plan

Based on the task list and any actionable emails from Step 0, propose 3-7 tasks for today. Consider:

- **Overdue tasks first** — these are already late
- **High priority items** — anything with `priority:H`
- **Email-derived tasks** — flag these as NEW so the user knows they don't exist yet
- **Mix of projects** — don't let one project dominate unless the user is focused on it
- **Realistic scope** — a day has limited hours, don't propose 15 tasks
- **Quick wins** — include 1-2 small tasks that can be knocked out fast for momentum

Present the proposed plan as a numbered list with task IDs, project, and description. Mark email-derived items clearly. For example:

```
Here's my suggested plan for today:

1. [#11] Personal: Check insurance for car dent (HIGH PRIORITY)
2. [#14] Personal: Cancel Viborg hotel and rebook Golf-Hotellet
3. [NEW] Personal: Figma subscription renews Apr 21 — cancel or confirm (from email)
4. [#10] Rental: Pay SEOM
5. [#5]  Rental: Thermostat installation (plan with Kris)

Want to adjust this list? I can add, remove, or swap items before we lock it in.
```

### Step 3: Iterate on feedback

The user may say things like:
- "Remove #5, I can't do that today"
- "Add the Nick task too"
- "Swap the hotel thing for the windshield"
- "Looks good" / "Let's go" / "Approved"

Keep adjusting and re-presenting until they approve.

### Step 4: Lock in the plan

Once approved:

1. First, create any NEW tasks that came from email triage or the conversation:

```bash
task add project:Personal "Figma subscription renews Apr 21 - cancel or confirm" due:eod
```

2. Then set `due:eod` on all existing tasks that were selected:

```bash
task <ID1> <ID2> <ID3> ... modify due:eod rc.confirmation=off
```

3. Confirm the full plan:

```bash
task due:today list
```

## Tips

- **Setting a task's due date to "today" always uses `due:eod`, not `due:today`.** `due:today` resolves to `00:00` of today, so the task shows as overdue for the entire waking day. `due:eod` resolves to `23:59:59`, which is the intended "do it before the day ends" semantics. This applies to both `task add` and `task modify`. For *filtering* (e.g. `task due:today list`), `due:today` is still correct — the filter matches any time on today's date.
- Task IDs are **not stable** — they can change when tasks are completed or deleted. When working across multiple commands in a sequence, re-check IDs if significant time has passed.
- Use `task export` for JSON output when you need to process tasks programmatically.
- The `rc.confirmation=off` flag skips "are you sure?" prompts, which is necessary for non-interactive use.
- The TUI is available via `taskwarrior-tui` (aliased to `td`) for interactive browsing, but for agent use the CLI is better.
- When adding tasks from conversation context (the user mentions something in passing), confirm before adding — don't silently capture todos the user didn't explicitly ask for.
