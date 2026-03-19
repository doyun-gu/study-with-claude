# study-with-claude

Turn Claude into your personal exam prep system. Drop your lecture PDFs and notes into module folders, and Claude becomes a strict-but-fair tutor that tracks your progress, analyzes past papers, diagnoses weak areas, and generates practice exams.

**V2: Now works with Claude Desktop + Claude Code together.** Claude Desktop is your conversational tutor. Claude Code is the engine that runs heavy analysis in the background.

All study data stays local on your machine.

---

## How It Works

```
┌─────────────────────────────────────┐
│       Claude Desktop (tutor)         │
│  "Explain buck converters"          │
│  "Analyze my past papers"           │
│  "What are my weak areas?"          │
└───────────┬────────────┬────────────┘
            │ logs Q&A   │ creates task
            ▼            ▼
     .study/qna-log  .study/tasks/pending/
            │            │
            │     ┌──────▼──────────────┐
            │     │   Study Daemon       │
            │     │   (background)       │
            │     │                      │
            │     │   Worker online?     │
            │     │   ├─ Yes → dispatch  │
            │     │   └─ No  → local     │
            │     └──────┬──────────────┘
            │            │
            │     ┌──────▼──────────────┐
            │     │   Claude Code        │
            │     │   /init-session      │
            │     │   /past-papers       │
            │     │   /diagnose          │
            │     │   /drill /flash      │
            │     └──────┬──────────────┘
            │            │
            ▼            ▼
     ┌───────────────────────────┐
     │    .study/ state files     │
     │    (source of truth)       │
     └───────────────────────────┘
```

**Claude Desktop** answers your questions conversationally, logs every Q&A, and delegates heavy tasks (past paper analysis, diagnostics, material scanning) to Claude Code.

**Claude Code** runs in the background via the daemon, processing tasks and updating state files that Desktop reads.

**The daemon** bridges them — watches for task files, dispatches to Claude Code (locally or on a remote worker), and syncs results.

---

## Install

### Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [Claude Desktop](https://claude.ai/download) (optional but recommended)
- Node.js (for Claude Desktop MCP integration)
- Your lecture materials (PDFs, markdown notes, images)

### Quick Start

```bash
# 1. Clone and install (one-time)
git clone https://github.com/doyun-gu/study-with-claude.git ~/study-with-claude
cd ~/study-with-claude && bash install.sh

# 2. Add your course materials to ~/study/
# Symlink existing folders (recommended — originals stay where they are):
ln -s ~/Documents/EE301-Circuits ~/study/EE301-Circuits
ln -s ~/Documents/MATH201-Algebra ~/study/MATH201-Algebra

# Or copy directly:
cp -r ~/Downloads/EE301-slides ~/study/EE301-Circuits

# 3. Initialize with Claude Code
cd ~/study && claude
/init-session    # Scans your materials, builds indexes, asks for exam dates
```

The installer sets up everything in one step:
1. Bootstraps `~/study/` with CLAUDE.md, 14 slash commands, and tools
2. Starts the background daemon and task queue
3. Configures Claude Desktop's filesystem MCP server (if Desktop is installed)
4. Generates `desktop-instructions.md` for your Claude Desktop Project
5. Creates launchd services (macOS) for the daemon, daily review, and wake recovery

### Set Up Claude Desktop

1. **Restart Claude Desktop** after install (to load the filesystem MCP)
2. Look for **Connectors** in the chat menu — `filesystem` should be toggled on
3. Create a **Project** in Claude Desktop (e.g., "Study")
4. Paste the contents of `~/study/desktop-instructions.md` as the project's custom instructions
5. Start chatting in that project — ask about your course materials

---

## Architecture

### File Structure

```
~/study/                          # Your study workspace
├── CLAUDE.md                     # Study system instructions
├── .claude/commands/             # 14 slash commands for Claude Code
├── .study/                       # All persistent state (gitignored)
│   ├── context.md                # Module inventory
│   ├── content-index.md          # Topic → file:pages (reverse index)
│   ├── file-map.md               # File → topics (forward index)
│   ├── progress.md               # Coverage metrics, exam dates
│   ├── qna-log.md                # All Q&A history (Desktop + Code)
│   ├── big-picture.md            # Equations, definitions, concepts
│   ├── diagnosis.md              # Weak areas analysis
│   ├── past-paper-analysis.md    # Exam frequency matrix
│   ├── drill-log.md              # Drill scores, review schedule
│   ├── flash-log.md              # Flashcard spaced repetition
│   ├── daily-summary.md          # Auto-generated morning summary
│   ├── cheat-sheet.md            # Emergency reference
│   ├── weekly-plan.md            # Study schedule
│   ├── mock-exams/               # Generated practice exams
│   └── tasks/                    # Task queue
│       ├── pending/              # Desktop creates tasks here
│       ├── running/              # Daemon moves tasks here
│       └── done/                 # Completed tasks with output
├── .study-daemon/                # Background daemon
│   ├── study-daemon.sh           # Main daemon (watches tasks)
│   ├── daily-review.sh           # Scheduled daily review
│   ├── on-wake.sh                # Wake recovery
│   └── ctl.sh                    # Control script
├── .study-tools/                 # Rendering pipeline
│   ├── render.sh                 # Markdown → HTML with LaTeX
│   └── template.html             # Browser template
├── EE301-Circuits/               # Module (or symlink)
│   ├── week-01/
│   │   └── slides.pdf
│   └── past-papers/
│       └── 2024-exam.pdf
└── MATH201-Linear-Algebra/       # Another module
```

### Token-Efficient Content Lookup

The system builds two indexes when you run `/init-session`:

- **`file-map.md`** (forward index): maps each file to topic-coherent page ranges
- **`content-index.md`** (reverse index): maps each topic to specific file:page locations

When you ask a question, Claude reads the index first (small file) to find exactly which pages to read, instead of scanning entire PDFs. This dramatically reduces token usage and response time.

### Task Queue

Claude Desktop delegates heavy work by creating task files:

```
.study/tasks/pending/2024-03-19-143022-past-papers.task.md
```

The daemon picks this up, runs Claude Code with the appropriate command, and writes results to `.study/` state files. Claude Desktop reads those files for its next answer.

### Spaced Repetition

Four commands form a feedback loop:

1. **`/drill`** — generates questions, grades answers, tracks with SM-2 intervals
2. **`/flash`** — rapid-fire flashcards from big-picture.md
3. **`/review`** — daily dispatcher surfacing items where `next_review ≤ today`
4. **`/diagnose`** — reads both logs as weakness signals

---

## Commands

### Claude Code (terminal)

| Command | What It Does |
|---------|-------------|
| `/init-session` | Scan materials, detect modules, set exam dates, build indexes |
| `/why [question]` | Direct Q&A with sourced answers and equations |
| `/past-papers` | Analyze past exams, build frequency matrix |
| `/diagnose` | Find weak areas, knowledge gaps, study priorities |
| `/big-picture` | Extract every equation, definition, theorem |
| `/mock-exam` | Generate practice exam matching past paper style |
| `/drill [topic]` | Active recall — Claude asks, you answer, Claude grades |
| `/flash [module]` | Rapid-fire flashcards with spaced repetition |
| `/review` | Daily review — clears spaced repetition queue |
| `/where-i-am` | Progress dashboard with coverage and countdown |
| `/weekly-plan` | Structured 7-day study plan |
| `/timer [hours]` | Study timer with audio alert |
| `/i-am-fucked` | Emergency cheat sheet — ruthlessly prioritized |
| `/notion-update` | Sync to Notion (optional) |

### Claude Desktop (conversational)

Ask naturally — Desktop reads your indexed state files and answers from your actual materials:

- *"Explain how a buck converter works"*
- *"What are my weak areas in Power Electronics?"*
- *"Analyze my past papers"* → delegates to Claude Code
- *"Quiz me on SVM"* → runs drill session directly
- *"What should I study today?"* → reads daily summary

Every question is auto-logged to `qna-log.md`, feeding the diagnosis and progress tracking.

---

## Daemon Control

```bash
# Check status
~/study/.study-daemon/ctl.sh status

# View logs
~/study/.study-daemon/ctl.sh logs

# Start/stop/restart
~/study/.study-daemon/ctl.sh start
~/study/.study-daemon/ctl.sh stop
~/study/.study-daemon/ctl.sh restart

# Sync state from remote worker
~/study/.study-daemon/ctl.sh sync
```

### Background Services (macOS)

| Service | What it does | Schedule |
|---------|-------------|----------|
| Task daemon | Watches for tasks, dispatches to Claude Code | Always running |
| Daily review | Runs `/review`, writes `daily-summary.md` | 8:00 AM daily |
| Wake recovery | Collects remote results, re-queues interrupted tasks | On laptop wake |

---

## Remote Worker (Optional)

If you have a second machine (e.g., Mac Mini, home server) that's always on, heavy tasks can run there while you close your laptop.

### Setup

1. Configure SSH access to your worker: `ssh my-worker` should work without password
2. Install Claude Code on the worker and run `claude login`
3. Edit `~/.study-daemon/config`:

```bash
REMOTE_HOST="my-worker"           # SSH alias
REMOTE_STUDY_DIR="$HOME/study"
REMOTE_CLAUDE="$HOME/.local/bin/claude"
REMOTE_DOCS="$HOME/Documents"
```

4. Restart the daemon: `~/study/.study-daemon/ctl.sh restart`

### How it works

- Daemon checks if the worker is reachable before each task
- If online: syncs state → dispatches via `nohup` (survives SSH disconnect) → collects results
- If offline: falls back to running locally
- When your laptop wakes: `on-wake.sh` collects any completed remote tasks and syncs state

---

## Organizing Your Materials

### Module Structure

Any top-level directory (except `.claude`, `.git`, `.study`, etc.) is a study module:

```
~/study/
├── EE301-Circuits/
│   ├── week-01/
│   │   └── slides.pdf
│   ├── week-02/
│   │   └── lecture.pdf
│   └── past-papers/
│       └── 2024-exam.pdf
├── MATH201-Linear-Algebra/
│   └── ...
```

### Using Symlinks

If your materials are in another location (e.g., iCloud, Dropbox, university drive):

```bash
ln -s ~/Documents/My-Courses/EE301 ~/study/EE301-Circuits
```

The original files stay where they are. study-with-claude sees them through the symlink.

### Supported Files

| Type | Support |
|------|---------|
| `.pdf` | Full — Claude reads text and images |
| `.md` | Full |
| `.txt` | Full |
| `.png`, `.jpg` | Full — diagrams, schematics, handwritten notes |
| `.pptx`, `.docx` | Not supported — convert to PDF first |

---

## Example Workflow

```
Session 1 (setup):
  /init-session       → Scans materials, builds indexes
  /past-papers        → Analyzes exam patterns
  /big-picture        → Extracts all equations

Daily (Claude Desktop):
  "What should I study today?"    → Reads daily summary
  "Explain [concept]"             → Answers from your materials
  "Quiz me on [topic]"            → Interactive drill
  "What are my weak areas?"       → Triggers background diagnosis

Weekly:
  /weekly-plan        → Plan the week
  /mock-exam          → Practice under exam conditions
  /diagnose           → Update weak areas

Before exam:
  /i-am-fucked        → Emergency cheat sheet
```

---

## Privacy

All data stays local. The `.study/` directory is gitignored. Materials never leave your machine unless you use Notion sync.

## The Teaching Approach

Claude operates as a **strict but fair lecturer** — asks what you think first, corrects misconceptions directly, cites specific sources. `/why` gives direct answers. `/i-am-fucked` switches to supportive coach mode.

## Contributing

Contributions welcome. Ideas: additional file format support, group study features, Anki export, Linux systemd support.

## License

MIT
