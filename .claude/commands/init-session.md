Bootstrap study session — scan all materials, detect modules, and set exam dates. Supports **resume across sessions** via checkpoint — if scanning is interrupted (session limit, context overflow), run `/init-session` again to pick up where you left off.

## Instructions

You are initializing a study session. Follow these steps precisely.

### Step 0: Merge Daily Q&A + Check for Checkpoint

**Merge any unmerged daily Q&A files from Claude Desktop:**
1. List all `.md` files in `.study/qna-daily/`
2. If any exist: read each one, append entries to `qna-log.md` (dedup by concept — increment `asked_count` on matches), update `total_questions` and `last_updated` in the YAML header, then delete the daily files.

**Check for checkpoint:**

Read `.study/.init-checkpoint.md`. If it exists:

1. Parse the frontmatter for `status`, `total_files`, `total_pages`, `processed`, and `pages_processed`
2. Print resume status:
   ```
   Init session in progress — [processed]/[total_files] files, [pages_processed]/[total_pages] pages ([page_%]%).
   Est. tokens remaining: ~[remaining_pages × 1500 / 1000]K
   Continue scanning, or restart from scratch? [continue/restart]
   ```
3. If the student says **continue** (or just presses enter / says yes): skip to Step 2 (resume scanning from unprocessed files)
4. If the student says **restart**: delete `.study/.init-checkpoint.md`, then continue to Step 1

If the checkpoint does not exist, continue to Step 1.

### Step 1: Detect Modules & Build File Inventory

Scan the top-level directories in the repository root. Any directory NOT in the exclusion list (`.claude`, `.study`, `.study-tools`, `.git`, `past-papers`, `example`, `node_modules`, `.context`) is a study module.

For each module found, recursively find all files:
- **Readable:** `.pdf`, `.md`, `.txt`, `.png`, `.jpg`, `.jpeg`
- **Unreadable (flag):** `.pptx`, `.docx`, `.xlsx` — warn the student to convert these to PDF

**Count PDF pages and check file sizes** (for progress tracking and strategy classification):
```bash
find . -name "*.pdf" ! -path "./.study/*" ! -path "./.claude/*" -exec mdls -name kMDItemNumberOfPages -raw {} \; -print 2>/dev/null
```
This outputs `page_count\nfilepath` pairs. Parse the output to get per-file page counts. If `mdls` returns `(null)` for a file, estimate 20 pages. For non-PDF files (`.md`, `.txt`), count as 1 page each. Sum all page counts to get `total_pages`.

```bash
find . -name "*.pdf" ! -path "./.study/*" ! -path "./.claude/*" -exec stat -f "%z %N" {} \;
```

**Classify each PDF** for processing strategy:
- **standard** — <10 MB AND <200 pages → Read tool (20 pages/request)
- **large** — ≥10 MB OR ≥200 pages → `pdftotext` text extraction (50 pages/batch)
- **oversized** — ≥20 MB OR ≥500 pages → `pdftotext` + TOC-first progressive scan

**Check for pdftotext** (required for large/oversized PDFs):
```bash
bash .study-tools/pdf-extract.sh --check
```
If not available, warn the student: `"⚠ pdftotext not found. Large PDFs will be processed slowly (5 pages at a time). Install with: brew install poppler"`

Write the initial checkpoint `.study/.init-checkpoint.md`:

```markdown
---
status: scanning
started: YYYY-MM-DD
last_updated: YYYY-MM-DDTHH:MM:SS
total_files: N
total_pages: N
processed: 0
pages_processed: 0
---

# Init Checkpoint

## Modules

### [Module Name]
- **Path:** /absolute/path/to/module
- **Subdirectories:** week-01, week-02, labs, ...

## File Inventory

- [ ] relative/path/to/file1.pdf (24p, 2MB) [standard]
- [ ] relative/path/to/file2.pdf (640p, 20MB) [oversized]
- [ ] relative/path/to/notes.md (1p)
...

## Processed File Data

<!-- file-map entries appended here as files are scanned -->

## Exam Dates

<!-- filled in Step 5 -->

## Warnings

- [any unreadable files that need conversion]
```

### Step 2: Scan Materials (Batched + Checkpointed)

Process files in **batches of ~10 files**. For each batch:

1. Take the next ~10 unchecked (`[ ]`) files from the File Inventory
2. For each file in the batch, use the strategy matching its classification:

   **Standard PDFs** (<10 MB, <200 pages):
   - Read with the Read tool, 20 pages at a time
   - Extract key topics, equations, definitions, and concepts
   - Identify topic-coherent page ranges (2-15 pages each) based on heading changes, new theorem/definition introductions, and subject shifts

   **Large PDFs** (≥10 MB OR ≥200 pages):
   - Extract text with: `bash .study-tools/pdf-extract.sh <file> <start> <end>`
   - Process 50 pages of text at a time (text uses ~5x fewer tokens than visual PDF reads)
   - Extract key topics, equations, definitions from the text content
   - Note pages referencing figures/diagrams (look for "Figure", "Fig.", "Diagram", "see illustration") — flag these for visual reads on demand
   - Identify topic-coherent page ranges from the text content

   **Oversized PDFs** (≥20 MB OR ≥500 pages):
   - **Phase 1 — TOC scan:** Run `bash .study-tools/pdf-extract.sh --toc <file>` to extract first 15 pages. Parse the table of contents to identify chapter/section structure with page numbers.
   - **Phase 2 — Selective deep scan:** For each chapter/section found in the TOC, extract 3-5 representative pages (start of chapter + pages with key terms) using `bash .study-tools/pdf-extract.sh <file> <start> <end>`. Extract topics, equations, definitions from these samples.
   - **Build skeleton index:** Map all chapter/section headings to page ranges. Mark fully-scanned ranges as `scanned` and unscanned ranges as `skeleton`. The skeleton entries still appear in the file-map and content-index with `[skeleton]` tags so `/why` and other commands know these pages exist but haven't been deeply indexed yet.
   - **Phase 3 is deferred:** Remaining pages are scanned on-demand when the student asks about those topics (via `/why`, `/drill`, etc.). When a skeleton entry is accessed, the command should extract the full text for those pages, update the file-map and content-index to remove the `[skeleton]` tag, and answer the question.
   - Print notice after processing:
     ```
     ⚠ [filename] (N pages) — skeleton index built from TOC + selective scan.
       Scanned: ~N pages | Skeleton: ~N pages (will scan on demand)
       Deep scan available via /big-picture when you have session budget.
     ```

   **No pdftotext fallback:** If `pdftotext` is not available for large/oversized PDFs, use the Read tool with **5 pages at a time** (not 20) to stay under request size limits. This is slower and uses more tokens — warn the student.

   For markdown/text files: use H2/H3 section headings as the unit instead of pages
3. After completing the batch, update `.study/.init-checkpoint.md`:
   - Mark each processed file as `[x]` in the File Inventory
   - Update `processed`, `pages_processed`, and `last_updated` in frontmatter
   - Append file-map entries to the **Processed File Data** section, one per file:

   ```markdown
   ### [relative/path/to/file.pdf]
   - **Pages:** N | **Type:** lecture slides

   | Pages | Topics | Key Content |
   |-------|--------|-------------|
   | 1-3 | Course overview | Syllabus, grading |
   | 4-11 | Basic circuit elements | Resistors, capacitors, inductors |
   ```

4. Print batch progress with page-based metrics:
   ```
   ━━━ Batch N complete ━━━
   Files:  [processed]/[total_files]
   Pages:  [pages_processed]/[total_pages]  ([page_percentage]%)
   Est. tokens remaining: ~[remaining_pages × 1500 / 1000]K
   ━━━━━━━━━━━━━━━━━━━━━━━
   Safe to stop and resume with /init-session.
   ```
   Token estimate: ~1.5K tokens per PDF page (average for lecture slides). This helps students gauge how many sessions they'll need.

5. Continue to next batch. Repeat until all files are processed.

When all files are processed, proceed to Step 3.

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

Update the checkpoint's Exam Dates section with the dates.

### Step 6: Generate/Update `.study/context.md`

First, ensure all `.study/` subdirectories exist:
```bash
mkdir -p .study/rendered
mkdir -p .study/mock-exams
```

Create or update `.study/context.md` using data from the checkpoint's Modules, File Inventory, and Processed File Data sections:

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

### Step 6b: Generate `.study/file-map.md`

Using the Processed File Data from the checkpoint (do NOT re-read any source files), write `.study/file-map.md`:

```markdown
---
generated: YYYY-MM-DD
total_files: N
total_pages: N
---

# File Map

## [Module Name]

### [relative/path/to/file.pdf]
- **Pages:** N | **Type:** lecture slides

| Pages | Topics | Key Content |
|-------|--------|-------------|
| 1-3 | Course overview | Syllabus, grading |
| 4-11 | Basic circuit elements | Resistors, capacitors, inductors; passive sign convention |
| 12-18 | Ohm's Law, KVL, KCL | Derivation, series/parallel circuits |

### [relative/path/to/textbook.pdf]
- **Pages:** 640 | **Type:** textbook | **Scan:** skeleton

| Pages | Topics | Key Content | Status |
|-------|--------|-------------|--------|
| 1-45 | Fundamentals | Basic theory, core definitions | scanned |
| 46-120 | Advanced Analysis | *From TOC: "Ch. 3 — Advanced Analysis"* | skeleton |
| 121-135 | Design Methods | Key theorems (sampled pp.121-125) | partial |
| 136-200 | Applications | *From TOC: "Ch. 5 — Applications"* | skeleton |

### [relative/path/to/notes.md]
- **Sections:** N | **Type:** notes

| Section | Topics | Key Content |
|---------|--------|-------------|
| ## Basic Elements | Resistors, capacitors | Component equations, energy storage |
| ## Kirchhoff's Laws | KVL, KCL | Statement, sign conventions |
```

For **oversized PDFs**, include a `Status` column: `scanned` (fully indexed), `partial` (key pages sampled), or `skeleton` (from TOC only — will be scanned on demand). Skeleton entries should still list the topics from the TOC heading so they appear in the content-index for lookup.

Keep page ranges topic-coherent — group by subject, not by fixed chunk size. Aim for ~3-4K tokens for a typical 5-module course.

### Step 6c: Generate `.study/content-index.md`

Invert the file-map to create a reverse index (topic → locations):

- For each topic mentioned in any file-map entry, collect all file+page locations where it appears
- Alphabetize entries within each module
- Add a type tag based on content type: `theory`, `formula`, `theorem`, `theorem+examples`, `theorem+derivation`, `method`, `derivation`, `examples`, `definition`, `law`
- Include common aliases in parentheses for fuzzy matching: e.g., `Thevenin's theorem (Thevenin equivalent)`
- Use `§` prefix for markdown section references

Write `.study/content-index.md` with this structure:

```markdown
---
generated: YYYY-MM-DD
total_entries: N
modules: [Module1, Module2]
---

# Content Index

## [Module Name]

| Topic | Locations | Type |
|-------|-----------|------|
| KCL | week-01/slides.pdf pp.15-18, week-01/notes.md §Kirchhoff's-Laws | law |
| Norton's theorem | week-03/slides.pdf pp.19-30 | theorem+examples |
| Ohm's Law | week-01/slides.pdf pp.12-13, week-01/notes.md §Basic-Elements | law |
| Thevenin's theorem (Thevenin equivalent) | week-03/slides.pdf pp.3-18, week-03/notes.md §Thevenin | theorem+examples |
| Advanced Analysis | textbook.pdf pp.46-120 | skeleton |
| Design Methods | textbook.pdf pp.121-135 | partial |
```

Aim for ~3K tokens for 150 entries. This index must be generated from the file-map data — no additional file reads.

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

### Step 8: Cleanup

Delete `.study/.init-checkpoint.md` — all data has been persisted to final state files.

### Step 9: Print Terminal Summary

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
