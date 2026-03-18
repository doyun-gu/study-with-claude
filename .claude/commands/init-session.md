Bootstrap study session — scan all materials, detect modules, and set exam dates.

## Instructions

You are initializing a study session. Follow these steps precisely:

### Step 1: Detect Modules

Scan the top-level directories in the repository root. Any directory NOT in the exclusion list (`.claude`, `.study`, `.git`, `past-papers`, `example`, `node_modules`, `.context`) is a study module.

For each module found, list:
- Module name (directory name)
- Subdirectories (weeks, past-papers, etc.)
- All files with their types

### Step 2: Scan Materials

For each module, recursively find all files:
- **Readable:** `.pdf`, `.md`, `.txt`, `.png`, `.jpg`, `.jpeg`
- **Unreadable (flag):** `.pptx`, `.docx`, `.xlsx` — warn the student to convert these to PDF

For each readable file:
- Read the content (for PDFs over 100 pages, read 20 pages at a time)
- Extract key topics, equations, definitions, and concepts
- Note which week/section it belongs to

### Step 3: Detect Changes (if `.study/context.md` already exists)

Compare the current file listing with the previous scan:
- New files added since last scan
- Files modified since last scan
- Files deleted since last scan
- New modules added or removed

### Step 4: Detect Material Gaps

For each module, check for:
- Missing weeks in the sequence (e.g., week-01, week-03 but no week-02)
- Modules with very few files
- Weeks with no lecture materials

### Step 5: Exam Dates (first run only)

If `.study/progress.md` does NOT exist or has no exam dates:
- Ask the student for the exam date of EACH detected module
- Accept dates in any format, store as ISO 8601 (YYYY-MM-DD)
- Calculate days remaining for each exam
- If the student doesn't know a date, store as "TBD"

### Step 6: Generate/Update `.study/context.md`

First, ensure all `.study/` subdirectories exist:
```bash
mkdir -p .study/rendered
mkdir -p .study/mock-exams
```

Create or update `.study/context.md` with this structure:

```markdown
---
last_scan: YYYY-MM-DD
modules_count: N
total_files: N
---

# Study Context

## Modules

### [Module Name]
- **Path:** /path/to/module
- **Weeks detected:** week-01, week-02, ...
- **Files:**
  - week-01/slides.pdf — [brief topic summary]
  - week-01/notes.md — [brief topic summary]
  - ...
- **Topics covered:** [list of key topics detected]
- **Gaps:** [missing weeks or sparse content]

### [Next Module]
...

## Changes Since Last Scan

- [List of new/modified/deleted files, or "First scan — no previous data"]

## Material Warnings

- [List of unreadable files that need conversion]
- [List of detected gaps]
```

### Step 7: Initialize/Update `.study/progress.md`

If `.study/progress.md` doesn't exist, create it:

```markdown
---
first_session: YYYY-MM-DD
last_session: YYYY-MM-DD
total_sessions: 1
total_questions: 0
---

# Study Progress

## Exam Dates

| Module | Exam Date | Days Remaining |
|--------|-----------|----------------|
| [Module] | YYYY-MM-DD | N |

## Topic Coverage

### [Module Name]
- [ ] [Topic 1]
- [ ] [Topic 2]
...

## Session Log

- YYYY-MM-DD: Initial scan. N modules, N files detected.
```

If it already exists, update `last_session`, increment `total_sessions`, recalculate days remaining, and add a session log entry.

### Step 8: Print Terminal Summary

Print a clean summary to the terminal:

```
╔══════════════════════════════════════╗
║         STUDY SESSION INIT          ║
╠══════════════════════════════════════╣
║ Modules: N                          ║
║ Files scanned: N                    ║
║ Changes: N new, N modified          ║
║ Gaps detected: N                    ║
╠══════════════════════════════════════╣
║ EXAM COUNTDOWN                      ║
║ [Module]: NN days (YYYY-MM-DD)      ║
║ [Module]: NN days (YYYY-MM-DD)      ║
╠══════════════════════════════════════╣
║ Warnings: N files need conversion   ║
╚══════════════════════════════════════╝
```

If there are material gaps or approaching exams (<14 days), highlight them.

After initialization, remind the student of key commands:
- `/why [question]` — ask anything about your materials
- `/diagnose` — find your weak areas
- `/where-i-am` — see your progress
