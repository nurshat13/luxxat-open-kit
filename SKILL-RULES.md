# The skill rules

## Contents

- How to check
- The 13 rules
- The hook (rule 10)
- Test prompts (rule 11)
- Writing a NEW skill — the checklist
- Sources

Every skill in this kit follows these 13 rules. They come from Anthropic's
skill-authoring guide and the Claude Code skills + hooks docs. Rules 1, 2, 5, 9
and 13 can be checked by a script; the others are read by a person.

## How to check

This kit does not ship an audit script. Quick manual checks:

```bash
wc -l skills/*/SKILL.md                                  # rule 1: body <= 500 lines
grep -L "^## Contents" skills/*/SKILL.md                 # rule 2: long files start with Contents
grep -rn "/Users/" skills/                               # rule 9: no machine-only paths
grep -rniE "step by step|show your reasoning" skills/    # rule 13
```

## The 13 rules

| # | Rule | The check | The fix |
|---|---|---|---|
| 1 | **Progressive disclosure.** SKILL.md body <= 500 lines; detail in its own files; every file linked straight from SKILL.md (one level deep) | body line count; files only reachable through another file | move detail that only some jobs need into `references/<topic>.md`; link it from SKILL.md with one line saying WHEN to read it |
| 2 | **Contents list.** Any .md over 100 lines starts with `## Contents` | first 25 lines of every file | one bullet per `##` section, same order as the file |
| 3 | **Degrees of freedom.** Exact script or command where a mistake costs money/data; plain goal where many ways work | read each step: what would a mistake cost? | lock costly steps to a script; loosen the rest |
| 4 | **Test on the models that run it.** Small model: enough guidance? Mid model: clear and efficient? Large model: not over-explained? | which model runs the skill (the agent definition pins it) | step-by-step text written for older models is a candidate to TEST without, not to delete blind |
| 5 | **Only what Claude can't work out.** Third-person description, <= 1024 chars, says WHAT + WHEN | description length and voice; paragraphs explaining general knowledge | cut to the house facts: prices, paths, names, rulings, incidents; "Builds X. Use when Y." |
| 6 | **Workflows + checklists.** Long jobs = numbered steps, a copy-and-tick checklist, a go-back line after each check | jobs with >= 4 steps | number the steps, add `- [ ]` lines, "If X fails, go back to Step N" |
| 7 | **Feedback loops.** Quality-critical work runs check -> fix -> repeat until it passes; validators name the problem AND what exists | scripts that print "Error" only | "Field 'x' not found. Available: a, b, c" |
| 8 | **Common patterns.** Templates say strict or default; style-heavy output has input/output pairs; branching jobs have a written fork | templates without a strictness line | "ALWAYS use this exact structure" vs "sensible default, use judgment"; "Creating? -> A. Editing? -> B" |
| 9 | **Shareable.** Every tool named with its install line in a `## Needs` section; no paths that exist only on one machine; forward slashes | `/Users/<name>/...`, backslashes, tools with no install line | `brew install ffmpeg`, `npm i puppeteer-core`; `~/...` or paths inside the skill |
| 10 | **Hooks for must-hold rules.** A rule that must hold every time lives in a hook, not in capitals | never/always/must lines — which one costs money, data or a client when missed? | `hooks/guard-bash.sh` (below); keep the rest as plain words with the reason beside them |
| 11 | **Test before the skill.** Three real tasks + a baseline run without the skill, in a FRESH session | `evals/evals.json` beside the skill | three prompts with `expected_behavior`; re-run after every big change |
| 12 | **Most important instructions at the top.** After compaction only the first few thousand tokens of an invoked skill survive | what sits in the first 60 lines | the binding rules and the Contents list first; history and long examples lower or in their own file |
| 13 | **Never ask Claude to echo its reasoning.** "think step by step and write it out" can trip a reasoning-extraction refusal on some models | grep: think step by step, show your reasoning, write out your thinking | ask for the answer plus a short explanation or a summary of the actions taken |

House carve-outs (so the rules do not fight the doctrine):

- The TOKEN RULES block (`TOKEN-DISCIPLINE.md`) stays verbatim in every brief —
  it is a rule-12 item, not rule-5 fat.
- Owner rulings stay in the skills. They ARE the "company details" rule 5 keeps.
  Trim the retelling, keep the ruling and its reason.
- The human's gates, money, publishing and credentials are human-only by
  `CLAUDE.md`. The hook enforces the agent-side rules only.

## The hook (rule 10)

`hooks/guard-bash.sh` is a `PreToolUse` hook on `Bash`. It denies, with a reason
that names the incident, these commands — and nothing else:

| Blocked | Why (the incident) |
|---|---|
| `flutter clean` (any spelling: fvm, SDK-path) | it wiped `build/` under a running chain |
| `git reset --hard`, `git checkout -- <path>`/`.`, `git restore <path>`, `git clean -f`, `git stash` (and push/pop/drop/clear/apply), `git push --force`, `git branch -D` | a commit swallowed another agent's staged files; a builder erased hours of uncommitted work |
| `git show <rev>:<path> > <path>` (redirect into the tree) | the exact command of the second incident above |
| `git commit` with `Co-Authored-By` | house hard line: no co-author trailers (delete the rule if yours differs) |
| `find /` | ran for over an hour at full CPU |
| `--update-goldens` with no test path | a blanket run re-baked unrelated goldens |

It is registered in `.claude/settings.json` (see the header of the script),
with the script copied into `<project>/.claude/hooks/`. Settings hooks run inside
subagents too, so every builder is bound. It is a settings hook, not a SKILL.md
frontmatter hook, because frontmatter hooks register only when that skill is
invoked and resolve relative paths against the cwd; the settings form binds every
session from its first command.

It matches COMMANDS, not words: quoted strings and heredoc bodies are blanked
before matching (a commit message that names a banned command passes), while
`sh -c "..."` payloads are matched. Self-test: `bash hooks/guard-bash.sh --test`.

## Test prompts (rule 11)

`<skill>/evals/evals.json` — the structure from Anthropic's guide:

```json
[{"skills": ["my-skill"],
  "query": "continue the sprint",
  "files": [],
  "expected_behavior": ["reads the plan + handoff before any code", "..."]}]
```

Three prompts per skill: the common case, the edge the skill exists for, and a
near-miss that should NOT trigger it. Run each in a fresh session with the skill
on and off after a big change.

## Writing a NEW skill — the checklist

Copy this into the reply and tick it:

```
- [ ] Three test prompts written and run WITHOUT the skill (baseline noted)
- [ ] description: third person, WHAT + WHEN, <= 1024 chars, one quoted line
- [ ] The binding rules + the Contents list in the first 60 lines
- [ ] Body <= 500 lines; everything else in references/<topic>.md, linked from SKILL.md
- [ ] ## Needs with an install line per tool; no /Users/... paths
- [ ] Costly steps = exact command; open steps = plain goal
- [ ] Long jobs: numbered steps + checklist + go-back line
- [ ] Any must-hold rule -> hooks/guard-bash.sh (or a reason why words are enough)
- [ ] No "show your reasoning" lines
- [ ] The manual checks under "How to check" pass
- [ ] Linked into the place your tool loads skills from (and copied into projects that run it in the cloud)
```

If a check fails, go back to the failing rule before committing.

## Sources

- platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices — rules 1–9, 11
- code.claude.com/docs/en/skills — rules 10–12 (frontmatter reference, "evaluate and iterate")
- code.claude.com/docs/en/hooks — the hook format; settings hooks also run inside subagents
