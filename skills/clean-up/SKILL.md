---
name: clean-up
description: System care for the owner's Mac — kill orphaned headless/test leftovers, sweep stale session scratchpads, report disk/RAM/CPU health. Conservative by design (never sudo, never user files, never build caches). Also runs a weekly hygiene sweep (stale-memory and untouched-skill FLAGS, report-only). Appends a dated entry to a system-care log. Built for headless runs (claude -p, small model, low effort) fired by a weekly routine, or "my mac is slow". TRIGGER on "/clean-up", "clean up my computer", "mac running slow/hot", "read the system care log".
---

# Clean-up (system care)

## Needs

- macOS (the process and path classes below are Mac-specific), no sudo, ever.
- A studio root folder, written `<studio-root>` below (the folder that holds your projects).
- A log file path: `<studio-root>/system-care.log.md` (the skill creates it).
- Section 5 (backup freshness) needs your own backup script, for example
  `<studio-root>/bin/sync-backup.sh`. That script is NOT in this kit. Delete section 5 if you have none.
- Section 4's skill-rules check uses the manual commands in `SKILL-RULES.md` ("How to check"); there is no audit script in this kit.

One run = act on the SAFE classes below, report everything else. If a judgment call appears, don't act — report it.

## 1. Kill (safe classes ONLY)

Processes matching ALL of: (a) name/args contain `headless_shell`, `chromedriver`, `Chrome for Testing`, `--headless`, or `flutter_tester`; (b) started >2 hours ago (`ps -axo pid,etime,command`). These are QA/test leftovers — live QA runs are minutes long. Kill with plain `kill` (no -9 first); record pid + command + age for the log. NEVER kill: regular Chrome/Safari windows, the Claude app, `node` servers you run on purpose, anything you cannot positively match to the signatures.

## 2. Sweep (safe paths ONLY)

- `/private/tmp/claude-<uid>/*`: delete subdirectories whose newest file is >7 days old (dead session scratchpads).
- `$TMPDIR` files matching `*.mp4|*.wav|frames_*` >7 days old.
- NOTHING else. Never: project `build/`/`.dart_tool/` (expensive rebuilds), `~/Library`, Xcode DerivedData, user documents.

## 3. Report

- Disk free (`df -h /`), top 5 RAM + top 5 CPU processes (`ps -axo rss,pid,comm | sort -rn | head`), count of chrome/node processes.
- Largest 5 items under `<studio-root>` by `du -sh` (report only — deleting there is never this skill's call).

## 4. Hygiene sweep (report-only — NEVER edit or delete anything here)

Stale memory is worse than no memory, because the agent acts on it with confidence. This section only flags; the owner (or a session the owner directs) does the pruning.

- **Memory review candidates**: files in `~/.claude/projects/<project-key>/memory/` (excluding MEMORY.md) not modified in >45 days — list name · age · the frontmatter `description:` line.
- **Index drift**: memory files NOT referenced from MEMORY.md, and MEMORY.md lines pointing at files that no longer exist.
- **Untouched skills**: skill folders whose SKILL.md is unmodified in >60 days — list name · age. Frame as "untouched — confirm still true", not as a defect (a stable skill is fine; a stale one lies).
- **Skill rules check**: run the manual checks from `SKILL-RULES.md` and paste the failing rows. A failure is a flag for the owner's next skills session, never a fix made here.

## 5. Log

Append a dated entry (killed list · MB freed · disk free · top consumers · backup-sync result · anything flagged-not-acted) to `<studio-root>/system-care.log.md` (create it if missing). Final output line = that log path + one-line verdict ("nothing needed killing" is a fine verdict).
