---
name: roll
description: Roll the CURRENT session onto a fresh context window without losing anything, in ANY project (an app repo, a client repo, an editor-extension session — it adapts to whatever project it is run in). Writes a complete, up-to-the-minute handoff for whatever this session was actually doing, checks for in-flight agents and background work first, verifies the handoff landed on disk, then hands back the commands that finish the roll. Never kills or touches a running process. This is the 50%-context ritual, done properly — the deliberate alternative to /compact, which decides for itself what mattered and throws the rest away. TRIGGER on "/roll", "roll the session", "roll me", "I'm running out of context", "write the handoff and let's start fresh", "context is filling up". DO NOT TRIGGER for a milestone hand-off with no roll intended (that is the standing sync-up step), for starting a session in another project, or for anything an autonomous loop already does — those roll themselves.
---

# Roll — fresh window, nothing lost

## Contents

- Two things this skill CANNOT do — say both, never fudge them
- Needs
- Works in any project
- Step 0 — check for in-flight work FIRST, and never touch it
- Step 1 — work out what this session actually did
- Step 2 — find the right handoff file
- Step 3 — write it
- Step 4 — verify it landed
- Step 5 — commit it if the repo is the memory
- Loop mode — keeping the handoff never-stale
- Step 6 — hand back the two commands
- What never goes in a handoff

The human works in ONE long-running main session. It fills up. `/compact`
compresses it, and compresses it wrongly — it is a summariser that decides on
its own what mattered, and whatever it drops is gone with no record.

This skill does the honest version: **write everything down properly first,
then start clean.** The handoff is a real file on disk, so it survives the
roll, survives a crash, and survives the laptop closing.

## Two things this skill CANNOT do — say both, never fudge them

**1. A skill cannot clear the context itself.** Only the human can type
`/clear`. This skill does everything up to that line and hands over the exact
commands. Never claim the context was cleared — say what is true: the handoff
is written, and the next step is theirs.

**2. There is no such thing as clearing only the UNNECESSARY context.**
`/clear` clears ALL of it. Nothing selective exists, and pretending otherwise
would get the human to clear while believing something was kept. The
handoff is what makes clearing safe — it is not a filter on the context, it
is a replacement for it. So the handoff must be good enough to work from
cold, because after the clear it is the ONLY thing left.

## Needs

- `git` (the skill reads `git log` and `git status`; committing the handoff is optional).
- A place for the handoff: a `handoff/` folder, a root `HANDOFF.md`, or a plans folder.
- The project's `CLAUDE.md` (read first when present).
- Optional: the `/loop` command for loop mode; a SessionStart-on-clear hook that loads the handoff itself.

## Works in any project

This skill is not tied to one project. It runs wherever it is invoked — an app
repo, a client repo, a side project, an editor-extension session. Detect the project
from the working directory, never assume a path:

1. If the repo has a `handoff/` directory, use its convention.
2. Else if it has a root `HANDOFF.md`, use that.
3. Else if it has `docs/` or a plans directory, put `HANDOFF.md` at the repo
   root and say that a new file was created.
4. Else write `HANDOFF.md` at the repo root.

Read the project's own `CLAUDE.md` first if one exists — its conventions win
over this skill's defaults, always.

## Step 0 — check for in-flight work FIRST, and never touch it

Before writing anything, find out what is still running: subagents, running
background tasks, watches, a build or test in progress.

**Never stop, kill, interrupt, or wait on any of them.** They are not this
skill's business. `/roll` updates documents; it does not manage processes.

What to do instead:

- **Record them in the handoff.** A named list of what was running, what it
  was doing, and where its output will land. The new session must not
  re-launch work that is already in flight.
- **Warn the human before they clear.** Say it plainly, with the count:

  > 3 agents still running. `/clear` does not stop them, but their results
  > come back into a conversation that no longer exists — those results are
  > lost. Wait for them, or roll anyway and accept it.

  Then let the human decide. Do not decide for them, and do not stall the
  roll waiting for agents to finish.
- **Background shell jobs are different** — they keep running and their
  output survives in their own log files. Note where those files are, and
  the new session can pick them straight back up.

## Step 1 — work out what this session actually did

Do NOT summarise the transcript top to bottom. Answer these, from what
really happened in THIS session:

- **What changed on disk?** Files written, commits made (hashes), tests run
  and their real numbers. Check `git log --oneline -5` and `git status` in
  every repo touched — never trust memory over the repo.
- **What was decided, and why?** Decisions are the part `/compact` loses
  first and the part that is most expensive to rebuild. Include the reason,
  not just the ruling.
- **What is IN FLIGHT right now?** A half-finished edit, a running probe, a
  test that was red when the roll started. This is the highest-value block
  and the one a summariser always mangles.
- **What is waiting on the human?** Open questions, gates, decisions asked
  but not answered.
- **What is the very next action?** One sentence, specific enough to act on
  cold.
- **What was still running?** From step 0 — carried into the handoff so the
  new session knows not to duplicate it.

## Step 2 — find the right handoff file

Use the detection order under "Works in any project" above. In a studio
layout, project work goes to that project's `handoff/<name>-handoff.md` or its
chain doc; cross-project work goes to a root `HANDOFF.md`.

If several were touched, update the one for the work that is IN FLIGHT and
name the others in it.

**Update the existing file. Never create a parallel one.** A second handoff
is how the next session reads the wrong one.

## Step 3 — write it

Put the fresh block at the TOP, with the date and time, under a `## ROLLED <date>` heading.
Keep what is still true below it; mark superseded blocks as superseded rather
than deleting them — the history is why the decisions make sense.

Write for a session with **no memory of this conversation**. Every path
absolute or repo-relative, every command exact, every number real. If a test
count is claimed, it is because it was run in this session, not recalled.

## Step 4 — verify it landed

Read the file back and confirm the new block is actually there. A roll whose
handoff silently failed to write is the worst outcome this skill can produce
— worse than not rolling at all, because the human will clear the context
believing it is safe.

If the write failed: say so loudly, and tell the human NOT to clear.

## Step 5 — commit it if the repo is the memory

House rule: docs are the memory. If the handoff is git-tracked, commit it
(no co-author trailer). An uncommitted handoff is one disk failure from
never having existed. Do not push unless asked.

## Loop mode — keeping the handoff never-stale

`/roll` pairs with `/loop`: `/loop 30m /roll` keeps the handoff current on a
timer, so the moment the human decides to clear, the file is already fresh
and the roll costs nothing.

**In loop mode, behave differently:**

- Do steps 0 through 5 exactly as normal — the handoff is what the loop is
  for.
- **Do NOT print the `/clear` instruction.** The human is not rolling; the
  loop is just keeping the record warm. Telling them to clear every 30
  minutes is noise, and noise gets a useful loop switched off.
- Report one line: what changed since the last update, or that nothing did.
- **Never clear, never suggest clearing, never touch a process.**

Detect loop mode from the invocation (a `/loop` wrapper, or the human
saying "just keep the handoff fresh"). When in doubt, ask once, then stay in
that mode for the rest of the loop.

## Step 6 — hand back the two commands

Report, in this shape and nothing longer:

```
Handoff written: <path>
Committed: <hash or "not tracked">
It covers: <one line — the in-flight thing>
Still running: <count, or "nothing">

Now type:  /clear
Then:      continue from <path>
```

If anything is still running, put the warning from step 0 ABOVE this block —
the human must see it before they clear, not after.

If the SessionStart-on-clear hook is installed, say so and drop the second
line — the handoff loads itself.

## What never goes in a handoff

Secrets, API keys, tokens, or anything from a `.env`. If the session handled
one, write `<credential handled — regenerate if needed>` and nothing more.
