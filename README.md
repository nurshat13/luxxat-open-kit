# Luxxat Open Kit

The operating discipline of a one-person studio that ships mobile apps with a
team of AI coding agents. One human holds the gates. The agents do the work, and
an agent never accepts its own work.

It is a redacted copy of the studio's working files: every studio-specific fact is a
placeholder in angle brackets (`<founder>`,
`<studio>`, `<app>`, `<brand-color>`, `<org>/<repo>`, `<studio-email>`).

Written for a Flutter app studio; the stack lines (flutter clean, golden tests, FittedBox) are the parts to adapt first.
Repo: https://github.com/nurshat13/luxxat-open-kit

## What is inside

| File | What it is |
|---|---|
| `CLAUDE.template.md` | The root `CLAUDE.md` of the studio: roles, gates, token floor, state contract, QA rules, hard lines. A template, not a copy. |
| `hooks/guard-bash.sh` | A Claude Code `PreToolUse` hook that denies the commands that destroyed work in real incidents. Has a self-test (`--test`). |
| `TOKEN-DISCIPLINE.md` | The spend rules: the TOKEN RULES block for every brief, the tool-call and context caps, the hand-over inventory. |
| `SKILL-RULES.md` | 13 rules for writing a skill, plus a checklist for a new one. |
| `PLAYBOOKS.md` | Two checklists: the 5-attempt escalation ladder and the lean per-feature chain. |
| `agents/designer.template.md` | Designer role (opus): draws one batch, never decides taste. |
| `agents/developer.template.md` | Developer role (sonnet): builds ONE feature from a brief. |
| `agents/tester.template.md` | Tester role (opus): makes a feature verifiable, reads evidence. |
| `agents/reviewer.template.md` | Reviewer role (opus): report-only fresh eyes. |
| `agents/marketing.template.md` | Marketing role (opus): drafts copy and creatives, never publishes. |
| `agents/release.template.md` | Release role (opus): prepares the release, never uploads. |
| `agents/maintainer.template.md` | Maintainer role (opus): turns live data into the next plan. |
| `skills/roll/SKILL.md` | Roll a long session onto a fresh context window with a verified hand-off file. |
| `skills/clean-up/SKILL.md` | Weekly Mac system care: kill test leftovers, sweep scratch folders, report health. |

## How to start

1. Copy `CLAUDE.template.md` to the root of your studio folder as `CLAUDE.md`. Fill
   every placeholder. Delete the rows you do not need. Keep the rules and the reasons.
2. Copy `hooks/guard-bash.sh` to `<project>/.claude/hooks/`, run `chmod +x` on it,
   and register it in `.claude/settings.json` with the shape in the script header.
   Run `bash .claude/hooks/guard-bash.sh --test` to see it pass.
3. Copy `agents/*.template.md` to `~/.claude/agents/` (or `<project>/.claude/agents/`)
   as `<name>.md`. Fill the placeholders. Every brief you send must carry the TOKEN
   RULES block from `TOKEN-DISCIPLINE.md`.
4. Copy `skills/roll` and `skills/clean-up` into your skills folder. Read the
   `## Needs` section of each first.
5. Run your first sprint with the lean chain in `PLAYBOOKS.md`. When an item gets
   stuck, use the 5-attempt ladder. Never attempt 6.

## The rules in one breath

One human gate (idea, design, near-release build). The session routes and judges;
it spawns a stronger judge agent for judgment calls. Builders get ONE deliverable per
brief, a hard cap on tool calls and context, and a written hand-over when they hit it.
Rules that must hold live in a hook, not in capital letters.

## Who made it

One human and an AI team: @luxxatlabs on Instagram, YouTube and TikTok. The apps:
https://luxxatlabs.com

## License

License: not set yet — the owner picks one (MIT proposed). Until then, all rights reserved; read and adapt for your own studio.
