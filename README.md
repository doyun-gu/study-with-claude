# study-with-claude

Turn Claude Code into your personal exam prep lecturer. Drop your lecture PDFs and notes into module folders, and Claude becomes a strict-but-fair tutor that tracks your progress, analyzes past papers, diagnoses weak areas, and generates practice exams.

All study data stays local on your machine. No accounts, no servers, no subscriptions beyond Claude Code.

## Install (Recommended)

Install once, then use `/lets-go` to bootstrap any directory:

```bash
# One-time setup — makes /lets-go available everywhere
git clone https://github.com/yourusername/study-with-claude.git ~/study-with-claude
cd ~/study-with-claude && bash install.sh

# Then in any directory with your study materials:
cd ~/my-courses
claude
/lets-go     # bootstraps everything — copies commands, tools, CLAUDE.md
/init-session     # scan your materials and start studying
```

No need to clone the repo into every study folder. Your materials stay where they are.

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed and configured
- Your lecture materials (PDFs, markdown notes, images)
- Past exam papers (optional but highly recommended)

## Quick Start (Alternative: Clone Method)

```bash
# Clone the template
git clone https://github.com/yourusername/study-with-claude.git
cd study-with-claude

# Create your first module folder
mkdir -p EE301-Circuits/week-01

# Add your lecture materials
cp ~/Downloads/week1-slides.pdf EE301-Circuits/week-01/

# Add past papers (optional)
cp ~/Downloads/2024-exam.pdf EE301-Circuits/past-papers/

# Start Claude Code
claude

# Initialize your study session
/init-session
```

Claude will scan your materials, ask for your exam dates, and you're ready to go.

## Commands

| Command | What It Does |
|---------|-------------|
| `/init-session` | Scan materials, detect modules, set exam dates, bootstrap study state |
| `/why [question]` | Ask anything — get a direct, sourced answer with equations and citations |
| `/past-papers` | Analyze past exams, build a frequency matrix of tested topics |
| `/diagnose` | Find your weak areas, knowledge gaps, and study priorities |
| `/big-picture` | Extract every equation, definition, and theorem from your materials |
| `/mock-exam [module] [difficulty]` | Generate a practice exam matching past paper style |
| `/drill [topic]` | Active recall drill — Claude asks questions, you answer, Claude grades |
| `/flash [module]` | Rapid-fire flashcard session for equations, definitions, key facts |
| `/review` | Daily review dashboard — clears your spaced repetition queue |
| `/where-i-am` | Progress dashboard with coverage metrics and exam countdown |
| `/weekly-plan` | Generate a structured 7-day study plan |
| `/timer [hours]` | Set a study timer with audio alert (e.g., `/timer 2`) |
| `/i-am-fucked` | Emergency mode — ruthlessly prioritized cheat sheet for last-minute cramming |
| `/notion-update` | Sync study state to Notion (optional, requires Notion MCP) |

## How to Organize Your Materials

### Module Folders

Any top-level folder in this repo (except `.claude`, `.git`, `.study`, `past-papers`, `example`) is treated as a study module.

```
study-with-claude/
├── EE301-Circuits/              # Module 1
│   ├── week-01/
│   │   ├── slides.pdf
│   │   └── notes.md
│   ├── week-02/
│   │   └── lecture.pdf
│   └── past-papers/
│       ├── 2023-exam.pdf
│       └── 2024-exam.pdf
├── MATH201-Linear-Algebra/      # Module 2
│   ├── week-01/
│   │   └── chapter1.pdf
│   └── past-papers/
│       └── 2024-final.pdf
├── past-papers/                 # Cross-module papers go here
│   └── 2024-combined-exam.pdf
├── CLAUDE.md
└── README.md
```

### Naming Conventions

- **Modules:** Use any name you want — `EE301-Circuits`, `power-electronics`, `MATH201`. Keep it descriptive.
- **Weeks:** Use `week-01`, `week-02`, etc. for Claude to detect the sequence and spot gaps.
- **Past papers:** Put them in `[module]/past-papers/` or the root `past-papers/` folder.

### Supported File Types

| Type | Support |
|------|---------|
| `.pdf` | Full support — Claude reads text and images |
| `.md` | Full support |
| `.txt` | Full support |
| `.png`, `.jpg` | Full support — diagrams, schematics, handwritten notes |
| `.pptx`, `.docx` | Not supported — convert to PDF first |

## Setting Your Exam Dates

`/init-session` asks for exam dates on first run. These enable:

- Countdown timers in your dashboard
- Urgency-based prioritization in `/diagnose`
- Pace calculations in `/where-i-am` ("you need 0.6 topics/day to finish")
- Emergency alerts when exams are close

If you don't know an exam date yet, enter "TBD" — you can update it later by editing `.study/progress.md`.

## Tips for Best Results

1. **Start with `/init-session`** — everything else depends on it.
2. **Ask questions with `/why`** — this builds your Q&A log, which feeds into diagnosis and progress tracking.
3. **Run `/past-papers` early** — frequency analysis dramatically improves study prioritization.
4. **Check `/where-i-am` regularly** — stay aware of your coverage and pace.
5. **Run `/diagnose` weekly** — identifies gaps before they become problems.
6. **Start each session with `/review`** — clears your spaced repetition queue and keeps knowledge fresh.
7. **Use `/drill` after learning** — active recall right after studying is the most effective way to retain.
8. **Run `/flash` for memorization** — lock in equations and definitions with spaced repetition.
9. **Use `/mock-exam` for practice** — the interactive grading mode gives real feedback.
10. **Don't skip the strict lecturer feedback** — being corrected is how you learn.

## Viewing Rich Content

Equation-heavy commands (`/big-picture`, `/mock-exam`, `/past-papers`, `/weekly-plan`, `/i-am-fucked`) auto-open rendered HTML in your browser with properly typeset LaTeX equations, formatted tables, and styled markdown.

For any `.study/` file, you can manually render it:

```bash
bash .study-tools/render.sh .study/big-picture.md
```

This creates `.study/rendered/big-picture.html` and opens it in your default browser. Requires an internet connection on first load (MathJax and marked.js load from CDN, then cached by the browser).

The terminal still shows a concise summary for every command — the browser render is for detailed review.

## Notion Integration (Optional)

`/notion-update` syncs your study data to Notion, creating a Study Hub with databases for modules, Q&A, and past paper topics. This requires the Notion MCP server to be configured in Claude Code.

### Setup

1. Set up the [Notion MCP server](https://github.com/modelcontextprotocol/servers/tree/main/src/notion) for Claude Code
2. Connect it to your Notion workspace
3. Run `/notion-update` — it creates everything automatically

The command is fully self-contained. It creates its own "Study Hub" page and databases — no existing Notion structure required.

## Privacy

All your study data is stored locally in the `.study/` directory, which is gitignored. Your lecture materials, exam papers, question history, and progress data never leave your machine (unless you use the Notion sync).

```
.study/                    # All gitignored
├── context.md             # Module inventory
├── qna-log.md             # Your question history
├── progress.md            # Coverage and exam dates
├── past-paper-analysis.md # Exam topic frequencies
├── big-picture.md         # Equations and concepts
├── diagnosis.md           # Weak areas
├── cheat-sheet.md         # Emergency reference
├── weekly-plan.md         # Study schedule
├── drill-log.md           # Drill scores and review schedule
├── flash-log.md           # Flashcard inventory and spaced repetition
└── mock-exams/            # Practice exams
```

## The Teaching Approach

Claude operates as a **strict but fair lecturer**:

- When you ask questions casually, it'll ask what YOU think first, then correct or confirm
- `/why` bypasses this — direct answers with full citations
- Misconceptions are called out immediately
- Correct reasoning gets brief acknowledgment
- Everything is sourced back to your specific materials
- `/i-am-fucked` switches to supportive coach mode — no judgment, just help

## Example Workflow

```
Session 1:
  /init-session          → Scans materials, sets exam dates
  /past-papers           → Analyzes past exams
  /big-picture           → Extracts all equations
  /diagnose              → Identifies initial gaps

Session 2+:
  /review                → Clear today's spaced repetition queue (5-15 min)
  /why [question]        → Study specific topics
  /drill [topic]         → Test understanding of what you just learned
  /flash                 → Lock in equations and definitions
  /where-i-am            → Check progress

Weekly:
  /weekly-plan           → Plan the week
  /mock-exam             → Practice under exam conditions
  /diagnose              → Update weak areas

Before exam:
  /i-am-fucked           → Emergency cheat sheet
```

## Contributing

Contributions welcome. Some ideas:

- Support for additional file formats
- Group study features
- Export to Anki

## License

MIT
