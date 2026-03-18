# /where-is-god — Bootstrap study-with-claude in any directory

You are executing the `/where-is-god` bootstrap command. Follow these steps EXACTLY in order.

---

## Step 1: Resolve the source repo path

Run this command to find where the source repo lives:

```bash
readlink -f ~/.claude/commands/where-is-god.md 2>/dev/null || readlink ~/.claude/commands/where-is-god.md 2>/dev/null
```

Strip `/bootstrap/where-is-god.md` from the result to get `SOURCE_ROOT`.

If the readlink fails (file doesn't exist or isn't a symlink), print:

```
Error: where-is-god.md is not installed as a symlink.
Run: cd ~/study-with-claude && bash install.sh
```

Then STOP. Do not continue.

---

## Step 2: Safety check — don't bootstrap inside the source repo

Compare `SOURCE_ROOT` with the current working directory (`$PWD`).

If `$PWD` starts with `SOURCE_ROOT`, print:

```
Error: You're inside the source repo itself.
cd to your study directory first, then run /where-is-god.
```

Then STOP.

---

## Step 3: Detect current state

Check these conditions in the current directory:

- `CLAUDE.md` exists? If yes, does line 1 contain `<!-- study-with-claude -->`?
- `.claude/commands/drill.md` exists? (proxy for "already bootstrapped")
- `.study/` directory exists? Has any files inside?

---

## Step 4: Print the banner

Print this EXACTLY:

```
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║    ⚡  G O D   O F   T H U N D E R   I S   H E R E  ⚡   ║
║                                                          ║
║         study-with-claude — exam prep activated           ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

If already bootstrapped (`.claude/commands/drill.md` exists), add: `Updating existing installation...`

---

## Step 5: Copy system files

These are system files owned by study-with-claude. Always overwrite them.

### 5a: Commands

```bash
mkdir -p .claude/commands
```

Copy ALL `.md` files from `$SOURCE_ROOT/.claude/commands/` to `.claude/commands/`. Use the Read tool to read each source file and the Write tool to write each target file. There should be 14 command files.

### 5b: settings.local.json

Read `$SOURCE_ROOT/.claude/settings.local.json` for the source permissions.

- If `.claude/settings.local.json` does NOT exist in the target → copy the source file as-is.
- If `.claude/settings.local.json` EXISTS in the target:
  1. Read the existing file and parse `permissions.allow` array
  2. Read the source file and parse its `permissions.allow` array
  3. Merge: take the union of both arrays (no duplicates)
  4. Write back the merged result, preserving any other keys in the existing file

### 5c: .study-tools

```bash
mkdir -p .study-tools
```

Copy `render.sh` and `template.html` from `$SOURCE_ROOT/.study-tools/` to `.study-tools/`. Make `render.sh` executable:

```bash
chmod +x .study-tools/render.sh
```

---

## Step 6: Handle CLAUDE.md

Three scenarios:

### 6a: No CLAUDE.md exists
Copy `$SOURCE_ROOT/CLAUDE.md` to `./CLAUDE.md`. Print: `CLAUDE.md installed.`

### 6b: CLAUDE.md exists AND line 1 is `<!-- study-with-claude -->`
This is a study-with-claude CLAUDE.md — safe to overwrite. Copy from source. Print: `CLAUDE.md updated.`

### 6c: CLAUDE.md exists but line 1 is NOT `<!-- study-with-claude -->`
This belongs to another project. Print a warning:

```
⚠ CLAUDE.md conflict detected!
  Your current CLAUDE.md was NOT created by study-with-claude.

  Options:
    (a) Backup current to CLAUDE.md.backup and replace
    (b) Skip — keep your current CLAUDE.md (commands will still work)
    (c) Abort — stop bootstrap entirely

  What would you like to do? (a/b/c)
```

Wait for user response and act accordingly. If (a), run:
```bash
cp CLAUDE.md CLAUDE.md.backup
```
Then copy from source.

---

## Step 7: Create directories

Only create if they don't already exist. NEVER touch existing contents.

```bash
mkdir -p .study/rendered
mkdir -p .study/mock-exams
```

---

## Step 8: Update .gitignore

If `.gitignore` exists, check if it contains `.study/`. If not, append it:

```bash
echo ".study/" >> .gitignore
```

If `.gitignore` doesn't exist, create it with just `.study/`.

Print whether `.study/` was already in `.gitignore` or was added.

---

## Step 9: Print summary

Print a summary like this:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Bootstrap complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Commands:  14 slash commands installed
  Tools:     render.sh + template.html
  CLAUDE.md: [installed / updated / skipped]
  State:     .study/ [created / already existed]
  Gitignore: .study/ [added / already present]

  Next steps:
    1. Add your study materials to module folders
    2. Run /init-session to scan and set up

  Ready to study!
```

---

## Important rules

- NEVER delete or modify anything in `.study/` — that's student data
- ALWAYS overwrite `.claude/commands/`, `.study-tools/` — those are system files
- The 14 command files and settings are the "system" — `.study/` is "user data"
- If any step fails, print a clear error and stop. Don't continue with a broken state.
