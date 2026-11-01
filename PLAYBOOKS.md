# Playbooks

## The 5-attempt ladder
For ANY stuck problem (failing test, review finding that will not die, build break,
pixel diff that will not converge). One attempt = hypothesis -> change -> verify.
- [ ] Attempts 1-3: the same builder (a sonnet agent) iterates. Resume it; it has the context.
- [ ] Attempts 4-5: stop it. Spawn a FRESH opus agent with a failure dossier
      (what was tried, exact errors, relevant files).
- [ ] After attempt 5: STOP. Never attempt 6. Mark the item blocked in the plan with a
      banner: what it is, what was tried, the open question. Ask <founder>:
      give guidance / skip and continue the order / cut scope.
- [ ] Write the attempt counter into the hand-off file, so a resumed session or a
      fresh agent never restarts the ladder from zero.
- [ ] No "done" without a fresh proving command run in THIS session (analyzer, test
      suite, screenshot diff), its output read, its exit code checked. The
      orchestrator's acceptance follows the same rule.

## The lean per-feature chain
Per feature, inside a sprint:
1. [ ] Builder (sonnet): code -> analyzer -> the feature's crucial tests (money and
       date maths, balances, sync merge, import/export, purchases) -> ONE debug boot
       smoke with a log grep -> ONE release pixel shot per screen with a drawn-element
       checklist. Report the diff %; a fix round only for a diff above 5 % or a missing
       element. No masks, no board loops.
2. [ ] Reviewer (opus) ONLY for money, sync, data, purchases or security. No per-item tester.
3. [ ] Device or emulator boot ONLY for app shell, wide-width layout, permissions or a
       native plugin. No second-platform run per item.
4. [ ] Caps: coordinator (opus) 200 tool calls, builders 120. The session judges and
       commits. Commit your own files by path.

Once per release candidate:
5. [ ] Persona walks per feature: `ideal` and `bad` (the state checklist lives in `bad`),
       in ONE language. Re-walk only the features that changed since the last walked build.
6. [ ] The device leg once (several window sizes) plus ONE run on the second platform.
7. [ ] ONE tester reads the contact sheets into a per-screen table; ONE reviewer over the
       whole release diff; the full suite once; the phone comparison once.
8. [ ] The human's phone check is the taste judge and the last gate.

If a step fails, go back to the step that made the failing artifact, not to step 1.
