#!/usr/bin/env bash
# guard-bash.sh - PreToolUse(Bash) hook for Claude Code: your must-hold rules as code.
# WHAT    : denies a short list of commands that destroyed work in real incidents (each reason says why).
#           A rule that must hold every time lives in a hook, not in capital letters in a prompt.
#           It runs for the main session AND for every subagent.
# IO      : JSON on stdin (tool_input.command); deny/ask JSON on stdout, exit 0. Silent exit 0 = allowed.
# MATCHES : COMMANDS, not words. Quoted strings and heredoc bodies are blanked first (a commit message that
#           mentions "flutter clean" passes); the payload of sh -c "..." / bash -c '...' IS checked.
# REGISTER: save as <project>/.claude/hooks/guard-bash.sh, run chmod +x on it, then add to .claude/settings.json:
#   {"hooks":{"PreToolUse":[{"matcher":"Bash","hooks":[{"type":"command",
#     "command":"\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/guard-bash.sh","timeout":10}]}]}}
# ESCAPE  : GUARD_BASH_OFF=1 in the environment skips every check (the human owner only).
# TEST    : bash .claude/hooks/guard-bash.sh --test     ADAPT: RULES below is plain data; edit it.

[ "${GUARD_BASH_OFF:-0}" = "1" ] && exit 0

# --test never reads stdin (an open, empty stdin would block cat forever)
if [ "${1:-}" = "--test" ]; then GUARD_INPUT="{}"; else GUARD_INPUT="$(cat)"; fi
export GUARD_INPUT
exec python3 - "$@" <<'PY'
import json, os, re, sys

# ASK, not deny: the owner gets an approval prompt and can approve each capture.
SCREEN_REASON = ("ASK from guard-bash.sh: this command captures the owner's whole screen (screencapture, ffmpeg -f avfoundation, "
  "ImageGrab/pyautogui/mss/CGDisplayCreateImage). An OS-level capture can catch unrelated private windows, "
  "so the owner approves each one. Prefer the WEB PAGE only: headless Chrome --screenshot, "
  "puppeteer page.screenshot, or the browser tool's own screenshot.")
ASK_REASONS = {SCREEN_REASON}

RULES = [
  # (name, regex on the command-only text, reason)
  ("flutter clean",
   r"(^|[;&|(\s])(fvm\s+)?(\S*/)?flutter\s+clean(\s|$)",
   "BLOCKED by guard-bash.sh: 'flutter clean' is never run by an agent (it wipes build/ under a running build or test chain). Fix the build without it; if a clean is truly needed, the owner runs it."),
  ("tree-writing git",
   r"(^|[;&|(\s])git\s+(-C\s+\S+\s+)?(reset\s+--hard|checkout\s+--(\s|$)|checkout\s+\.(\s|$)|restore\s+(?!--staged)\S|clean\s+-[a-zA-Z]*f|stash(\s*$|\s+(push|drop|clear|pop|apply|-))|push\s+[^|;&]*(--force|-f(\s|$))|branch\s+-D)",
   "BLOCKED by guard-bash.sh: tree-writing git (reset --hard / checkout|restore of paths / clean -f / stash / push --force / branch -D) is not run by agents in shared worktrees (these commands have destroyed other agents' uncommitted work). Commit your own files by path with 'git add <paths> && git commit'; ask the owner for anything that discards work."),
  ("git show redirect",
   r"git\s+show\s+[^|;&]*:[^|;&]*>\s*[^/\s]",
   "BLOCKED by guard-bash.sh: 'git show <rev>:<path> > <path>' overwrites a working file with an old version (this once erased hours of work). Write to a scratch path and diff instead."),
  ("find /",
   r"(^|[;&|(\s])find\s+/(\s|$)",
   "BLOCKED by guard-bash.sh: 'find /' scans the whole disk (it once ran for over an hour at full CPU). Scope the search to the project directory."),
  ("screen capture",
   r"(^|[;&|(\s])(\S*/)?screencapture(\s|$)|-f\s+avfoundation\b",
   SCREEN_REASON),
]

# Python/JS screen-grab calls hide inside heredocs and -c strings, so these are
# matched on the RAW command, but only as function calls (a doc that names them passes).
SCREEN_CALLS = r"ImageGrab\.grab\s*\(|pyautogui\.screenshot\s*\(|\bmss\.mss\s*\(|\bCG(Display|WindowList)CreateImage\s*\("

def strip_text(cmd):
    """Blank quoted strings + heredoc bodies; keep the payload of sh/bash -c "…" visible."""
    # heredoc bodies: from the line after <<WORD to the WORD line
    out, i, lines = [], 0, cmd.split("\n")
    while i < len(lines):
        m = re.search(r"<<-?\s*['\"]?([A-Za-z_][A-Za-z0-9_]*)['\"]?", lines[i])
        out.append(lines[i]); i += 1
        if m:
            word = m.group(1)
            while i < len(lines) and lines[i].strip() != word:
                i += 1
            i += 1
    s = "\n".join(out)
    payloads = []
    for m in re.finditer(r"(?:^|\s)-c\s+(\"((?:\\.|[^\"\\])*)\"|'([^']*)')", s):
        payloads.append(m.group(2) or m.group(3) or "")
    s = re.sub(r"\"(?:\\.|[^\"\\])*\"|'[^']*'", '""', s)
    return s + "\n" + "\n".join(payloads)

def check(cmd):
    text = strip_text(cmd)
    for name, rx, reason in RULES:
        if re.search(rx, text):
            return reason
    if re.search(SCREEN_CALLS, cmd):
        return SCREEN_REASON
    # co-author trailer: the commit MESSAGE is the quoted part, so look at the raw command
    if re.search(r"(^|[;&|(\s])git\s+(-C\s+\S+\s+)?commit\b", text) and re.search(r"co-authored-by", cmd, re.I):
        return "BLOCKED by guard-bash.sh: commit messages carry no Co-Authored-By trailer (house rule, see CLAUDE.md 'Hard lines'; delete this rule if your house allows trailers). Re-run the commit without the trailer."
    # blanket golden update: --update-goldens with no test path anywhere in the command
    if re.search(r"--update-goldens", text) and not re.search(r"--update-goldens\s+[^-\s]|test/\S+_test\.dart", text):
        return "BLOCKED by guard-bash.sh: '--update-goldens' needs an explicit test path (a blanket run once re-baked unrelated goldens). Name the test file(s) whose goldens should move."
    return None

if len(sys.argv) > 1 and sys.argv[1] == "--test":
    cases = [
      ("flutter clean", True), (".fvm/flutter_sdk/bin/flutter clean && flutter pub get", True), ("fvm flutter clean", True),
      ("flutter build apk", False), ("git reset --hard HEAD~1", True), ("git -C /x checkout -- .", True),
      ("git checkout -b feat/x", False), ("git checkout feat/x", False), ("git restore lib/a.dart", True),
      ("git restore --staged lib/a.dart", False), ("git stash", True), ("git stash list", False), ("git stash pop", True),
      ("git push --force origin x", True), ("git push -u origin claude/x", False), ("git branch -D old", True),
      ("git show HEAD:lib/a.dart > lib/a.dart", True), ("git show HEAD:lib/a.dart > /tmp/x.dart", False),
      ("git commit -m 'fix' -m 'Co-Authored-By: Claude <x>'", True), ("git commit -m 'fix: thing'", False),
      ("find / -name foo", True), ("find . -name foo", False), ("flutter test --update-goldens", True),
      ("flutter test --update-goldens test/widgets/card_test.dart", False), ("ls -la", False),
      # words, not commands
      ("git commit -m 'hook: deny flutter clean / git reset --hard'", False),
      ("echo 'never run flutter clean' >> notes.md", False),
      ("python3 - <<'EOF'\nprint('flutter clean')\nEOF", False),
      ("cat > x.md <<EOF\ngit reset --hard is banned\nEOF", False),
      # evasion through -c payloads
      ("sh -c 'flutter clean'", True), ("bash -c \"git reset --hard\"", True),
      # screen capture
      ("screencapture -x /tmp/s.png", True), ("/usr/sbin/screencapture -R0,0,800,600 a.png", True),
      ("sh -c 'screencapture a.png'", True), ("ffmpeg -f avfoundation -i 1 out.mp4", True),
      ("python3 - <<'EOF'\nfrom PIL import ImageGrab\nImageGrab.grab().save('x.png')\nEOF", True),
      ("python3 -c 'import pyautogui; pyautogui.screenshot(\"a.png\")'", True),
      ("node -e 'require(\"mss\")'; python3 -c 'import mss; mss.mss()'", True),
      ("\"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome\" --headless=new --screenshot=a.png file:///x.html", False),
      ("node qa.js  # puppeteer page.screenshot", False),
      ("git commit -m 'guard: block screencapture and ImageGrab'", False),
      ("echo 'never run screencapture' >> notes.md", False),
      ("ffmpeg -i in.mp4 -vf fps=1 out_%03d.jpg", False),
    ]
    bad = 0
    for c, want in cases:
        got = check(c) is not None
        flag = "ok " if got == want else "BAD"
        bad += got != want
        print(f"{flag} {'DENY ' if got else 'allow'} {c.splitlines()[0][:60]}")
    print(f"{len(cases) - bad}/{len(cases)} as expected")
    sys.exit(1 if bad else 0)

try:
    cmd = json.loads(os.environ.get("GUARD_INPUT") or "{}").get("tool_input", {}).get("command", "")
except Exception:
    sys.exit(0)
reason = check(cmd) if cmd else None
if reason:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                      "permissionDecision": "ask" if reason in ASK_REASONS else "deny", "permissionDecisionReason": reason}}))
sys.exit(0)
PY
