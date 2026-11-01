<!-- WHAT: the root CLAUDE.md of a one-person studio that ships apps with a team of AI agents. -->
<!-- HOW AN AGENT READS IT: Claude Code loads this file in every session and subagent opened under this folder. Obey it as house law. -->
<!-- HOW TO ADAPT: replace every <placeholder>, delete the rows you do not need, keep the rules AND their reasons. -->
<!-- PLACEHOLDERS: <founder> <studio> <app> <brand-color> <org>/<repo> <studio-email> -->
<!-- A rule that must hold every single time belongs in hooks/guard-bash.sh, not only in this file. -->
<!-- PAIR WITH: TOKEN-DISCIPLINE.md, PLAYBOOKS.md, SKILL-RULES.md, agents/*.template.md. -->

# <studio> — root rules

This folder is the top of <founder>'s world. Every project (shipped, live, or in progress) lives in a subfolder; everything studio-level (identity, planning, content) lives in `brand/`. Sessions opened HERE work at studio level; sessions opened inside a project folder work on that project.

**Founder:** <founder> (solo). Public identity: one human running an AI team (the staff are AI agents; the founder is the only human gate). Brand color: <brand-color>.

## Operating model — the studio

- **Founder = CEO.** Owns taste, money, publishing, and three gates: approve the idea · approve the design · evaluate the near-release build. Everything else is delegated.
- **The session opened here = chief of staff.** Routes every request, plans, spawns and manages the staff, verifies their work with measurements (never trust, always probe), holds iteration caps, syncs the studio layer, and escalates ONLY the founder's own calls: the three gates, money, publishing, scope cuts, anything irreversible.
- **The staff (spawned agents):** designer (opus) draws · developer (sonnet) builds · tester + reviewer (opus) verify · marketing (opus) drafts · release (opus) prepares store artifacts · maintainer (opus) reads post-launch data · a browser driver (sonnet) does mechanical console chores, one at a time, local only. **No employee ever accepts their own work.** Nothing publishes without the founder.
- Console chores with no API or CLI run through the browser driver without asking. Money, publish buttons, pricing, credentials and claim changes stay founder-only. The safety layer's per-action confirmations are still asked.
- **Model doctrine:** the session runs on one strong model and routes and judges the routine. It SPAWNS a top-tier judge agent (fresh context; the brief = file paths + the rule set + the question, never the session's own conclusion) WITHOUT asking, whenever the call is judgment-grade: the plan review before a sprint · a design or taste verdict · the release-candidate accept/reject · an item stuck after the 5-attempt ladder · a concept lock · anything irreversible. Evaluative work = opus. Mechanical work = sonnet. Routing, plumbing, briefs, verification, commits and handoffs stay with the session. Why: a long session re-reads its whole history on every call, so the session stays cheap.
- **Escalation ladder:** any stuck problem gets at most 5 attempts (3 by the same builder, 2 by a fresh opus agent with a failure dossier). Then STOP and ask the founder. The counter lives in the hand-off file. See `PLAYBOOKS.md`.
- **Evidence before "done":** no completion claim without a fresh proving command run in this session and its output read.

**Token discipline (binding for every session and spawned agent, local or cloud).** The doctrine is `TOKEN-DISCIPLINE.md`. The floor that must hold even where that file never loads: every agent brief carries the TOKEN RULES block · tail or grep every command, full logs to files, grep before read, offset/limit reads, ≤ N-line summaries · a builder, tester or reviewer past ~120 tool calls or ~120K context (an opus coordinator past ~200) is STOPPED and hands over through a `handoff/evidence/<feature>/WIP.md` inventory to a fresh agent · ONE deliverable per builder brief, many short fresh agents over one long one · visual QA reads contact sheets and zooms only on suspects · resume an agent for delta work instead of spawning fresh · console drives are verified by read-only APIs, never by a second browser read · note the weekly usage % at session start and after the first feature.

The standing cadence: founder and chief of staff CONVERSE → decisions become plans → the staff executes autonomously to a near-release state → the founder steps back in to evaluate.

## What lives where

| Thing | Home |
|---|---|
| Identity, voice, colors (<brand-color>) | `brand/identity.md` |
| Project registry (single source of truth) | `PROJECTS.md` — update on EVERY status change |
| Portfolio performance and double-down decisions | `SCOREBOARD.md` — session-open ritual: if its newest snapshot is more than 7 days old, ask the founder for numbers before other work. |
| This folder itself | its own PRIVATE repo `<org>/<repo>`. Project folders are gitignored; they keep their own repos, because a cloud build loop clones ONE repo |
| Cross-project app code | `shared/`, its own repo; apps depend on it by path. **Extract on second use only** |
| Skills and agents | your skills repo, linked into `~/.claude/`; rules in `SKILL-RULES.md` |
| Must-hold agent rules | `.claude/hooks/guard-bash.sh`, registered in every project's `settings.json`; each denial names its incident |
| Cloud accounts | **`<studio-email>`, always**, for every console and cloud project. A personal account never owns a studio resource. Any agent that touches a console FIRST proves the account (CLI login list, `gh auth status`) and STOPS if it is not the studio account. A wrong-account resource is fixed by an ownership TRANSFER, never by delete and recreate (a deleted project id stays reserved for weeks) |
| Live QA driver (per app) | `<project>/tool/qa.sh` + `tool/walks/`, see QA rules |
| App code, app campaigns | each project's folder |

## QA rules

**Lean chain** (`PLAYBOOKS.md`). Per feature = analyzer + crucial unit tests + ONE debug boot smoke (log grep) + ONE release pixel shot per screen; a reviewer only for money, sync, data, purchases or security; no per-feature tester. At the release candidate = persona walks `ideal` + `bad` per feature, ONE device leg, ONE second-platform run, ONE tester, ONE reviewer, the full suite, the phone comparison. The founder's phone check is the taste judge.

**Tests:** crucial unit tests only (money and date maths, balances, sync merge, import/export, purchases). No widget tests by default. Screens are proven by boot smoke + pixel shot + walks. The full suite runs once before a release candidate. The Android emulator is the live-device leg; the iOS simulator gets ONE run per item and one per release candidate.

**One-language QA + re-test only what changed.**
1. Walks run in ONE language.
2. The UI must not break in other languages without a walk: no text in a fixed-width or fixed-height box; every `Text` in a `Row` sits in `Flexible`/`Expanded` with `maxLines` + ellipsis, or wraps; pills, chips, buttons, tabs use `FittedBox(fit: BoxFit.scaleDown)` or wrap; `EdgeInsetsDirectional`/`AlignmentDirectional` for right-to-left; dates and numbers through `intl`. A clip found later is fixed in the widget, not only by a shorter word.
3. Before any lane or release run, read the diff since the last walked build. Nothing walked changed (copy, QA-only code, store assets, logic pinned by unit tests) → skip the walk. Some features changed → walk only those. Walk everything only when many features, or a money · sync · data · purchase flow, changed. Analyzer and the full suite always run. Say the choice and the reason in one line.

**Analytics on every app.** An analytics SDK + a shared event package + a HOUSE EVENT SET (screens · onboarding · core action · paywall `source` · purchase · a closed `cta_tap` list) + a daily warehouse export. Set up at scaffold time; privacy forms declare it from build 1. Ad ID off, no tracking prompt, no free text, no personal data.

## Session routing — single entry

Every session opens HERE. The founder states the goal; the session decides where work executes.

**The state contract (where things land):**
- **Project-scoped state → the project's folder, always.** Code, plans (`docs/plans/`), handoffs (`handoff/`), tests, manifests, commits: all in `<project>/`, in that project's own git repo. Loops run against the project folder: every brief names the project dir explicitly, and commits happen in the project repo only.
- **Cross-project state → studio level.** The registry, `brand/` docs, `shared/` extractions.
- **The sync-up step (non-optional).** After any milestone in a project (feature shipped, release, status change, notable number), update that project's handoff AND the studio layer: its `PROJECTS.md` row, plus the content plan if the milestone feeds content. A milestone that never reached the registry didn't happen, as far as studio sessions are concerned. Then commit and push the studio repo: it is the ONLY backup of the house documents, and an uncommitted milestone is one disk failure from never having happened.
- Nested CLAUDE.md files still load: a project's own conventions apply to work in it.

**Starting a NEW project:** discuss and validate here → run a name-clearance check, then lock the NAME here → scaffold `<studio>/<app>/` (git init, seed CLAUDE.md, registry row `in-design`) → run your build chain (idea → design → plan → build → release) from this session against that folder.

**Cloud-ready scaffold (every new project)** so build loops can run in cloud sessions from day one:
1. A private GitHub remote `<org>/<app>`, created and pushed at scaffold time by the session with the founder's authorized `gh` (never a token in a brief).
2. `handoff/` git-TRACKED (cloud machines see only what is committed). Evidence images and logs under `handoff/evidence/` are gitignored; briefs and reports stay tracked.
3. The loop skills and permissions vendored into the project's own `.claude/` (user-level config never reaches cloud sessions).
4. A README recipe for the cloud environment (install the SDK, clone `shared/` beside the project).
5. The live-QA kit: `tool/qa.sh`, `tool/walks/`, a release walk script.
6. CI/CD from day one: a manual test lane and a `release`-branch lane (full suite → release walk → one version bump → test-track upload → tag) on a self-hosted runner. Nothing runs on every push. The founder keeps Submit and rollout.

## House voice

Report to the founder in Simplified Technical English (ASD-STE100): plain approved words, active voice, one idea per sentence. Paths, commands and numbers stay exact. This floor also reaches subagents and cloud sessions.

**Scope: it governs REPORTING (status, findings, plans, escalations), never the craft.** Scripts, ad copy, store listings and posts follow their own craft rules, which need metaphor and rhythm.

## Hard lines (everywhere)

Founder-only: publishing and posting, money and subscriptions, store clicks, pricing, credentials, claim changes. Docs are the memory: decisions land in files the same turn. No co-author trailers on commits.
