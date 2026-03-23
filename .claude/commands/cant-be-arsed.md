Auto-organize downloaded course files into a structured study folder with smart renaming, duplicate detection, and undo support.

The student tells you what they downloaded and where it should go. You find the right files and organize them.

Usage: `/cant-be-arsed [description] to [target]`

The `[description]` is natural language — the student describes what they downloaded. You figure out which files in the source directory match.

Examples:
- `/cant-be-arsed I downloaded the electric drives and machines module to ~/Documents/03-EEE/Year-3/Semester-II/Electric-Machines`
- `/cant-be-arsed downloaded MCEL30102 stuff to Documents/03-EEE/Year-3/Semester-II/Commercial-Development`
- `/cant-be-arsed induction machine lectures and tutorials to ~/study/induction-machines`
- `/cant-be-arsed the power electronics slides from ~/Desktop to ~/study/power-electronics`
- `/cant-be-arsed undo` (reverse the last organize operation)

Arguments: $ARGUMENTS

## Instructions

You are organizing a student's downloaded course files into a clean study-ready folder structure. The student describes what they downloaded in natural language — your job is to find those files and organize them intelligently.

### Step 0: Parse Arguments

Parse the `$ARGUMENTS` string:

1. **Undo mode:** If arguments contain only `undo`, skip to the **Undo** section at the bottom.
2. **Normal mode:** Split on the word `to` (the last occurrence, to handle descriptions containing "to").
   - **Left side** = description of what was downloaded + optional source path
   - **Right side** = target directory
   - If the description mentions a specific source path (e.g., "from ~/Desktop"), use that. Otherwise default source to `~/Downloads`
   - Expand `~` to the user's home directory
   - If `target` is a relative path without `~/` or `/`: treat it as relative to the current working directory

3. **Extract search intent from the description:**
   - Module name or code (e.g., "MCEL30102", "electric machines", "power systems")
   - File types mentioned (e.g., "lectures", "tutorials", "slides")
   - Any other context clues (e.g., "stuff I just downloaded", "everything from today")

### Step 1: Resolve Target Directory

Check if the target path exists:

**Case A — Exists:** Use it directly. Note any existing structure (week folders, naming conventions) to match.

**Case B — Doesn't exist, but close match found:**
Search for fuzzy matches:
```bash
# Check parent directories exist, find similar folder names
find "$(dirname "$TARGET")" -maxdepth 1 -type d 2>/dev/null | sort
```

If a similar directory exists (e.g., user typed `Semester-II` but `Semester-2` exists, or `Power-System` but `Power-Systems` exists):
- Ask: "Did you mean `[similar path]`? Or create new folder `[typed path]`?"
- Wait for confirmation before proceeding.

**Case C — Doesn't exist, no close match:**
- Ask: "Create `[target path]`?"
- If the parent directory also doesn't exist, show the full tree that will be created.
- Wait for confirmation.

### Step 2: Find Matching Files in Source

List all files in the source directory:
```bash
ls -la "$SOURCE"
```

**Use the student's description to find matching files.** Don't try to organize the entire source folder — only pick files that match what the student described.

**Matching strategy:**
1. **Module code match:** If the student mentioned a code like "MCEL30102", match files containing that code
2. **Topic match:** If the student said "induction machine" or "electric machines", match files with related keywords: `IM`, `induction`, `machine`, `motor`, `electric drive`
3. **Keyword match:** Match common course file keywords: `lecture`, `tutorial`, `quiz`, `exam`, `slides`, `notes`, `assignment`, `coursework`, `handbook`
4. **Timestamp clustering:** If the student said "stuff I just downloaded" or "what I downloaded today", group by modification date
5. **Related directories:** Include any directories in source that seem related (e.g., `code and report`)

**What to include:**

| Category | Extensions | Action |
|----------|-----------|--------|
| Course material | `.pdf`, `.md`, `.txt` | Include if matches description |
| Needs conversion | `.pptx`, `.docx`, `.xlsx` | Include with ⚠ warning |
| Code files | `.py`, `.m`, `.cir`, `.sp` | Include (→ `materials/code/`) |
| Related directories | folders matching description | Include (→ preserve structure) |

**What to always skip (regardless of description match):**
- Office temp files (`~$*`)
- System files (`.DS_Store`, `.localized`)
- App installers (`.dmg`)
- Personal photos (`DSCF*`, `IMG_*`, random UUIDs)
- Firmware files (`.uf2`)

**Present the matches to the student:**
```
Based on "[student's description]", I found [N] matching files:

  Lectures:  [list filenames]
  Tutorials: [list filenames]
  Quizzes:   [list filenames]
  Other:     [list filenames]

  ⚠ Needs conversion: [list .pptx/.docx files]

Also in source but NOT matching your description: [N] other files (ignored)
```

**If you're uncertain about some files, ask:**
```
Should I also include these?
  - [filename] (reason: [why it might match])
```

**If no files match the description at all:**
- List what IS in the source directory (brief summary by category)
- Ask: "I couldn't find files matching '[description]'. Can you clarify which files you mean?"

### Step 3: Detect Sub-groupings Within Matches

If all matched files clearly belong to one module, proceed to Step 4.

If the matched files seem to span multiple modules (e.g., different module codes):
- Present the groupings: "These files seem to cover [N] modules: [Module A] ([N] files), [Module B] ([N] files)"
- Ask if the student wants to organize all into separate subfolders under the target, or just one

### Step 4: Auto-Organize — Build the File Tree Plan

For each file, determine its destination using these rules (in priority order):

**1. Lecture materials — detect topic/week groupings:**
- Files with `IM1-3`, `L1-3`, or similar range indicators → group by range
- Files with `week 1`, `Week 2`, `W3` → `materials/week-NN/`
- Files with explicit lecture numbers → group by lecture range into logical weeks
- Paired files (e.g., `Lecture_slides_IM1-3.pdf` + `Lecture_notes_IM1-3.pdf`) → keep together in same folder
- If no week/lecture number detected → `materials/`

**2. Tutorials / Homework:**
- Files with `tutorial`, `homework`, `problem set`, `assignment` → `materials/tutorials/`
- Detect Q (questions) and A (answers) pairs: `Tutorial1Q` + `Tutorial1A` → keep paired
- Preserve the Q/A distinction in filenames

**3. Quizzes / Tests:**
- Files with `quiz`, `test`, `midterm` → `materials/quizzes/`

**4. Past papers / Exams:**
- Files with `exam`, `past paper`, `sample paper`, `final` (as in final exam, not "final version") → `past-papers/`

**5. Course admin:**
- Files with `outline`, `syllabus`, `schedule`, `handbook`, `guidelines` → root of module folder

**6. Coursework / Submissions:**
- Files with `coursework`, `submission`, `brief`, `example` → `materials/coursework/`

**7. Code files:**
- `.py`, `.m`, `.cir`, `.sp` → `materials/code/`

**8. Reference / supplementary:**
- Academic papers, textbook chapters, reference materials → `materials/references/`

**9. Everything else → `materials/`**

**Smart renaming rules:**
- Lowercase, kebab-case: `Commercial Development Week 1 2026 CVa.pdf` → `commercial-development-a.pdf`
- Strip year/semester from filenames (implied by folder location)
- Strip redundant words: "final", "2026", "_final_", "(1)"
- Keep version/part indicators: `a`, `b`, `v2`, `part-1`
- Keep meaningful suffixes: `Q` (questions), `A` (answers)
- Preserve original name in the manifest for traceability
- **If the file already has a clean, descriptive name — don't rename it**

**Duplicate detection:**
- Same filename at target → **skip**, report as duplicate
- Same file size + similar name (e.g., `file.pdf` vs `file-1.pdf`) → likely duplicate, compute MD5:
  ```bash
  md5 -q "$FILE1" "$FILE2"
  ```
  If hashes match → **skip**, report as duplicate
- Different content, similar name → **ask** which to keep or keep both

### Step 5: Present the Plan

Show the complete file tree with rename mappings:

```
📁 [target-folder-name]/
├── course-outline.pdf                    ← "Full Course Outline MCEL30102.pdf"
├── materials/
│   ├── week-01/
│   │   ├── lecture-slides.pdf            ← "Lecture_slides_IM1-3.pdf"
│   │   └── lecture-notes.pdf             ← "Lecture_notes_IM1-3.pdf"
│   ├── week-02/
│   │   ├── lecture-slides.pdf            ← "Lecture_slides_IM4.pdf"
│   │   ...
│   ├── tutorials/
│   │   ├── tutorial-1-questions.pdf      ← "Tutorial1Q_final.pdf"
│   │   ├── tutorial-1-answers.pdf        ← "Tutorial1A_final.pdf"
│   │   ...
│   └── quizzes/
│       ├── quiz-1.pdf                    ← "Quiz 1_final_.pdf"
│       ...
├── past-papers/
│   └── ...
│
│ ⚠ Needs PDF conversion:
│   slides-im-elec-mech.pptx             ← "Slides_IM_elec_mech_slip_frequency.pptx"
│
│ ⊘ Skipped (duplicates):
│   Lecture_notes_IM1-3-1.pdf             = Lecture_notes_IM1-3.pdf (same hash)
│
│ Move [N] files from [source] → [target]? [yes/no/edit]
```

**If the student says "edit":** ask what they want to change, adjust the plan, and re-present.

Wait for explicit confirmation before proceeding.

### Step 6: Execute the Move

For each file in the plan:

1. Create target directories if they don't exist:
   ```bash
   mkdir -p "$TARGET/materials/week-01" "$TARGET/materials/tutorials" ...
   ```

2. Move files (with rename):
   ```bash
   mv "$SOURCE/$ORIGINAL_NAME" "$TARGET/$NEW_PATH/$NEW_NAME"
   ```

3. After all moves complete, write the manifest.

### Step 7: Write the Organize Manifest

Create/append to `.study/organize-log.md` in the target directory:

```markdown
---
last_organized: YYYY-MM-DDTHH:MM:SS
total_operations: N
---

# Organize Log

## YYYY-MM-DD HH:MM — [source folder name]

**Source:** [full source path]
**Target:** [full target path]
**Files moved:** N
**Duplicates skipped:** N

| # | Original Path | Moved To | Renamed From |
|---|--------------|----------|--------------|
| 1 | ~/Downloads/Lecture_slides_IM1-3.pdf | materials/week-01/lecture-slides.pdf | Lecture_slides_IM1-3.pdf |
| 2 | ~/Downloads/Tutorial1Q_final.pdf | materials/tutorials/tutorial-1-questions.pdf | Tutorial1Q_final.pdf |
...

### Skipped (duplicates)
| Original | Duplicate Of | Reason |
|----------|-------------|--------|
| Lecture_notes_IM1-3-1.pdf | Lecture_notes_IM1-3.pdf | Same MD5 hash |

### Warnings
- `Slides_IM_elec_mech_slip_frequency.pptx` — needs conversion to PDF for study tools
```

Also create `.study/` directory if it doesn't exist:
```bash
mkdir -p "$TARGET/.study"
```

### Step 8: Scaffold Study Template (if needed)

If the target directory does NOT already have study-with-claude structure:

Check if the study-with-claude template exists:
```bash
ls ~/Developer/study-with-claude/subjects/_template/ 2>/dev/null
```

If the template exists, copy scaffold files:
```bash
cp ~/Developer/study-with-claude/subjects/_template/README.md "$TARGET/README.md"
cp ~/Developer/study-with-claude/subjects/_template/big-picture.md "$TARGET/big-picture.md"
cp ~/Developer/study-with-claude/subjects/_template/equations.md "$TARGET/equations.md"
cp ~/Developer/study-with-claude/subjects/_template/exam-prep.md "$TARGET/exam-prep.md"
cp ~/Developer/study-with-claude/subjects/_template/flashcards.md "$TARGET/flashcards.md"
cp ~/Developer/study-with-claude/subjects/_template/weak-areas.md "$TARGET/weak-areas.md"
```

If existing study files are already present, leave them untouched.

### Step 9: Respect Existing Structure

If the target folder already has organized content:

1. **Detect existing convention:**
   - Are folders named `week-01` or `Week 1` or `Lecture 1-3`?
   - Are files kebab-case or original names?
   - Is there a different subfolder structure?

2. **Match the existing pattern.** If the user has `Week 1/`, `Week 2/` folders, don't create `week-01/`.

3. **Slot new files into existing folders.** Don't reorganize what's already there.

4. **Flag conflicts:** "materials/week-01/ already has `lecture-slides.pdf` — skip or replace?"

### Step 10: Print Summary

```
✓ Organized [N] files into [target-name]/
  materials/week-01/   → [N] files
  materials/week-02/   → [N] files
  materials/tutorials/ → [N] files
  materials/quizzes/   → [N] files
  past-papers/         → [N] files

  Skipped: [N] duplicates
  ⚠ [N] files need PDF conversion (.pptx/.docx)

  Undo: run /cant-be-arsed undo
  Study: run /init-session to scan materials
```

---

## Undo Section

When the student runs `/cant-be-arsed undo`:

1. Find the most recent organize log:
   - Search for `.study/organize-log.md` in the current directory and recent target directories
   - If not found, check common locations: `~/Documents/`, `~/study/`

2. Parse the most recent operation block (latest `## YYYY-MM-DD` section)

3. Show what will be undone:
   ```
   Undo last organize (YYYY-MM-DD HH:MM)?
   [N] files will be moved back to [source]
   Original filenames will be restored.
   [yes/no]
   ```

4. On confirmation, reverse each move:
   ```bash
   mv "$TARGET/$NEW_PATH/$NEW_NAME" "$SOURCE/$ORIGINAL_NAME"
   ```

5. Clean up empty directories left behind:
   ```bash
   find "$TARGET/materials" -type d -empty -delete 2>/dev/null
   ```

6. Remove the operation block from the organize log.

7. Print: `✓ Undone. [N] files restored to [source].`
