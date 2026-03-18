Sync study state to Notion — create Study Hub structure on first run, then incremental updates.

**Requires Notion MCP to be configured.** If Notion tools are not available, inform the student:
> "Notion MCP is not configured. To set it up, follow the Notion MCP setup guide for Claude Code. This command is optional — all your data is already in `.study/` files."

## Instructions

### Step 1: Check Notion Connection

Verify Notion MCP tools are available. If not, display the setup message above and stop.

### Step 2: Check for Existing Study Hub

Search Notion for a page titled "Study Hub" using the Notion search tool.

- **If found:** This is an update run. Proceed to Step 4.
- **If not found:** This is first run. Proceed to Step 3.

### Step 3: Create Study Hub Structure (First Run Only)

Create the following Notion structure:

#### 3a. Study Hub Root Page

Create a page titled **"Study Hub"** with:

```
# Study Hub

---

> One-stop dashboard for exam preparation. Auto-synced from local study data via `/notion-update`.

---

## Overview

| Metric | Value |
|--------|-------|
| Modules | [N] |
| Total Questions Asked | [N] |
| Next Exam | [Module] — [Date] ([N] days) |
| Overall Readiness | [%] |

## Exam Countdown

| Module | Exam Date | Days Left | Coverage | Status |
|--------|-----------|-----------|----------|--------|
| [data from progress.md] |

## Quick Links
- Study Modules database (below)
- Q&A Log database (below)
- Past Paper Topics database (below)
```

#### 3b. Study Modules Database

Create a database titled **"Study Modules"** as a child of Study Hub with properties:

| Property | Type | Values |
|----------|------|--------|
| Name | Title | Module name |
| Status | Select | Active / Complete / Paused |
| Topics Covered | Number | Count of covered topics |
| Total Topics | Number | Count of all topics |
| Weak Areas | Number | Count of weak areas |
| Exam Date | Date | ISO date |
| Last Studied | Date | ISO date |
| Coverage | Number | Percentage (format as %) |

Add one entry per module from `.study/context.md`.

#### 3c. Q&A Log Database

Create a database titled **"Q&A Log"** as a child of Study Hub with properties:

| Property | Type | Values |
|----------|------|--------|
| Name | Title | Short question title |
| Module | Select | Module names from context |
| Topic | Text | Specific topic |
| Priority | Select | normal / high / critical |
| Asked Count | Number | Times asked |
| Date | Date | ISO date |
| Answer | Text | Summary of answer (truncate if very long) |

Populate from `.study/qna-log.md`.

#### 3d. Past Paper Topics Database

Create a database titled **"Past Paper Topics"** as a child of Study Hub with properties:

| Property | Type | Values |
|----------|------|--------|
| Name | Title | Topic name |
| Module | Select | Module names |
| Frequency | Number | Percentage (format as %) |
| Risk Level | Select | Always / Frequent / Sometimes / Rarely / Never |
| Avg Marks | Number | Average marks when tested |
| Last Tested | Text | Most recent year |

Populate from `.study/past-paper-analysis.md` (if it exists).

#### 3e. Per-Module Pages

For each module, create a sub-page under Study Hub titled **"[Module Name]"** with:

```
# [Module Name]

---

> [One-line module summary from context.md]

---

## Exam Info
- **Date:** YYYY-MM-DD
- **Days remaining:** N
- **Coverage:** N%

## Key Equations

[Top equations from big-picture.md for this module, using /equation blocks]

## Key Concepts

[Important definitions and concepts for this module]

## Weak Areas

[From diagnosis.md, filtered to this module]

## Recent Questions

[Last 10 Q&A entries for this module from qna-log.md]
```

### Step 4: Incremental Update (Subsequent Runs)

Read all `.study/` files and sync changes to Notion:

#### 4a. Update Study Hub Overview
- Update the overview table with current metrics

#### 4b. Sync Study Modules Database
- For each module: find existing entry by name, update properties
- Add new modules if they appeared since last sync

#### 4c. Sync Q&A Log Database
- For each Q&A entry: match on question text (fuzzy match on concept)
- Update `asked_count` and `priority` for existing entries
- Add new entries

#### 4d. Sync Past Paper Topics Database
- Match on topic name + module
- Update frequency and risk level
- Add new topics

#### 4e. Update Per-Module Pages
- Refresh equations, concepts, weak areas, and recent questions

### Step 5: Print Sync Report

```
╔══════════════════════════════════════╗
║        NOTION SYNC COMPLETE         ║
╠══════════════════════════════════════╣
║ Study Hub: [created/updated]        ║
║ Modules synced: N                   ║
║ Q&A entries synced: N new, N updated║
║ Past paper topics: N                ║
╠══════════════════════════════════════╣
║ View in Notion: [URL if available]  ║
╚══════════════════════════════════════╝
```

### Notion Formatting Conventions

Follow these style rules (referenced from claude-handler/notion/ conventions):

- **No emoji** in titles, headings, or body text
- **Headings:** H1 = page title only (set by Notion), H2 = major sections, H3 = subsections (max depth)
- **Dividers** (`---`) between every H2 section
- **Callouts:** Grey for summaries, yellow for warnings, blue for status
- **Bold:** Key terms on first introduction only
- **Code:** Inline code for file paths, commands
- **Equations:** Use Notion's `/equation` block for math
- **Database views:** At least 2 views per database. Default = Table (sorted by priority/date). Add Board view for Status-based databases.
- **Tags/selects:** All lowercase, hyphenated

### Important

- This command is **self-contained** — it creates everything it needs in whatever Notion workspace is connected
- No dependency on any existing Notion structure
- Match on names to avoid duplicates — never recreate existing pages/entries
- Truncate very long answers in Q&A to keep Notion pages readable (link back to local `.study/` for full content)
- If any Notion API call fails, report the error clearly and continue with other syncs
