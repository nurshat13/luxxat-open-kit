# Token discipline — the studio's spend rules

Binding for every session, every spawned agent, every skill, local or cloud.
These rules came from measuring real runs: one long builder agent re-read its
whole history on every tool call and ate most of a session's budget, while a
fresh agent that finished the same work from a written inventory cost a
fraction of that.

## What the measurements taught

- A long-running builder pays for its past on every step: each tool call
  re-reads the whole context. Many short agents beat one long agent.
- A visual pass over 100+ single screenshots costs about ten times a pass over
  a few labelled contact sheets, and finds the same defects.
- A browser driver's own read-back of what it typed can miss a same-length
  character swap. A read-only API byte check catches it, at a tiny fraction of
  the cost of driving the browser a second time.
- Resuming an agent for a delta review costs about a third of a fresh reviewer.

## Rules

**A. Every brief carries the TOKEN RULES block** (verbatim below). Agents pipe
every command through `tail`/`grep`; full logs go to files; reads use
offset/limit; grep before read; never re-read.

**B. Context cap + inventory hand-over.** An agent that passes **~120 tool
calls or ~120K context** is STOPPED by the orchestrator (the coordinator layer
of opus agents gets **200 tool calls**, because it holds small reads). The agent
writes a cold-resume inventory — sections `DONE / HOW TO RUN / GOTCHAS / OPEN /
attempt counters` — to `handoff/evidence/<feature>/WIP.md`, returns a ≤ 10-line
summary, and a FRESH agent finishes from that file. This hand-over is the
standard shape between builders, not an exception. The stuck-ladder attempt
counter does not reset on a hand-over.

**C. Narrow briefs.** ONE deliverable per builder (two only when they share one
file). Larger work is split into fresh agents that run in sequence (shared
files) or in parallel (disjoint files).

**D. Visual QA reads contact sheets.** The orchestrator builds grids (one sheet
per screen across locales/states, one per locale across screens; tiles at about
half size, labelled). The evaluator reads each sheet ONCE and zooms into an
original only for a suspect, with the zoom count capped in the brief. Never
hand 100+ single images to an evaluator.

**E. Model split stays.** Evaluative work = opus. Mechanical work = sonnet. The
session model judges, commits and syncs. Browser drives = ONE sonnet driver at
a time. The SESSION verifies drives through read-only APIs (byte checks), never
through a second browser read.

**F. Resume, don't respawn.** To continue an agent with its context intact (a
delta review, a re-check, "finish step 4"), message/resume it. Spawn fresh only
when the context itself is the problem (rule B).

**G. The orchestrator stays lean.** Read headings first, then sections; ask
agents for ≤ N-line summaries; keep own turns short; flush state to the
hand-off file the moment it exists so nothing is re-derived after a roll.

**H. Meter check.** Note the weekly usage % at session start and after the first
feature lands. A sprint costs roughly 4–6 times that first delta. Report it in
the hand-off.

**I. Parallel where disjoint, sequential where shared.** Agents that touch
different files run together. Shared resources run one at a time: the build
output folder (a QA build and a production build overwrite each other), the test
tree during a full run, one browser, one simulator.

**J. Console drives are chunked.** A browser driver's context grows with every
page it reads. One driver run covers a small, fixed chunk (for example ≤ 3
locales or ≤ ~60 fields), then returns; the next chunk is a fresh driver with
the same brief plus "start at chunk N". Read pages with `find`/`read_page`
(interactive filter) instead of screenshots; at most one screenshot per saved
chunk.

**K. Small contexts.** Target: average context per call **≤ ~100K**.
- The cap in rule B is the backstop. **Brief SIZE is the real control**: builders
  do not reliably self-stop on a written cap line, so the orchestrator checks
  the agent's tool-call count at each check-in and stops an over-cap agent (ask
  for WIP, stop, spawn fresh).
- **One deliverable per builder brief.**
- **Fresh over long.** A fresh agent from a WIP file starts small; a long one
  re-reads a huge history on every call. Prefer many short agents.
- **Briefs point, never paste.** Give paths + line ranges; the agent reads only
  what its one deliverable needs.
- Routine review/QC runs at medium effort; raise it only for hard triage.
- Re-measure weekly with your own usage meter and write the average context per
  call into the hand-off.

## TOKEN RULES block — paste into every agent brief

```
## TOKEN RULES (binding)
- Pipe every command through `| tail -n 30` or a targeted grep; redirect
  full output to a file under handoff/evidence/… and tail that.
- Grep before you read; read with offset/limit; never re-read a file you
  already read; never read a drive/test/build log in full.
- Final summary ≤ N lines. No code pastes — paths + one line each.
- If you pass ~120 tool calls, STOP: write the cold-resume inventory
  (DONE / HOW TO RUN / GOTCHAS / OPEN / attempt counters) to
  handoff/evidence/<feature>/WIP.md and return a ≤ 10-line summary.
```

## Where this is enforced

- `agents/*.template.md` — every agent definition carries the block (so it
  applies even when a brief forgets it).
- `CLAUDE.template.md` — the "Token discipline" paragraph in the operating model
  reaches subagents and cloud sessions that never load your user-level config.
- Your own usage meter (not included in this kit) — measures a session's spend by
  agent and flags agents over the rule-B caps.

## Coordinator cap

The opus COORDINATOR's cap is **200 tool calls**. Builders, testers and reviewers
stay at **120 / 120K**. The per-item staff = coordinator + builders (+ a reviewer
only for money, sync, data, purchases or security); no per-item tester.
