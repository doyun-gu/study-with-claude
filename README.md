# study-with-claude

Turn Claude into your personal study companion. Drop your course materials into subject folders, and Claude reads everything — then helps you understand it, quiz yourself, and prepare for exams.

Works for **any field**: engineering, medicine, law, business, sciences, humanities. No coding required.

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/doyun-gu/study-with-claude.git
cd study-with-claude

# 2. Run the installer
bash install.sh

# 3. Create a subject
bash scripts/new-subject.sh "Linear Algebra"

# 4. Drop your materials in
cp ~/Downloads/lecture-slides.pdf subjects/linear-algebra/materials/
cp ~/Downloads/week-*.pdf subjects/linear-algebra/materials/

# 5. Open in Claude and start studying
cd ~/study && claude
/init-session
```

---

## Setup

### Claude Code (CLI)

The installer handles everything:
```bash
bash install.sh
```

### Claude Desktop

1. Copy the MCP config: `setup/claude-desktop-config.example.json` → `~/Library/Application Support/Claude/claude_desktop_config.json`
2. Edit it — replace `YOUR_HOME_DIR` with your home directory path
3. Open `desktop-instructions-template.md`, replace `$STUDY_DIR` with your study path, paste into a Claude Desktop Project
4. Restart Claude Desktop

### Feynman Research Agent (optional)

Deep, multi-agent cited research for complex topics:
```bash
curl -fsSL https://feynman.is/install | bash
feynman setup
```

Then use `/deepresearch [topic]` in Claude Code, or ask Claude Desktop to research a topic deeply.

**Full setup guide:** [`setup/README.md`](setup/README.md)

---

## What You Can Do

### Ask anything about your materials

> *"Explain Gaussian elimination step by step"*
> *"What's the difference between Jacobi and Gauss-Seidel methods?"*
> *"Summarise Week 3 lectures"*

Claude reads your actual PDFs and notes, then answers with specific references.

### Build comprehensive references

> *"Build big picture for linear-algebra"*

Claude scans all your materials and generates:
- **big-picture.md** — complete topic overview, concept map, key definitions
- **equations.md** — every important equation with explanations
- **exam-prep.md** — practice questions at easy/medium/hard levels
- **flashcards.md** — quick review cards for key concepts

### Study actively

> *"Quiz me on Week 5"*
> *"Give me 5 practice problems on eigenvalues"*
> *"Flashcard session for root finding methods"*

Claude generates questions at your level and explains what you get wrong.

### Prepare for exams

> *"What topics are most likely on the exam?"*
> *"Explain this like I'm five: singular value decomposition"*
> *"What are my weak areas?"*

If you drop past exam papers into `materials/`, Claude identifies patterns and focuses your study time.

### Deep research (with Feynman)

> *"/deepresearch Nyquist stability criterion"*
> *"Compare Newton-Raphson vs bisection vs secant methods"*

Multi-agent research with cited sources — every claim backed by papers or authoritative references.

---

## Project Structure

```
study-with-claude/
├── subjects/
│   ├── _template/               # Template for new subjects
│   ├── numerical-analysis/      # Sample subject (included)
│   │   ├── README.md            # Subject overview
│   │   ├── materials/           # ← Drop your PDFs here
│   │   ├── big-picture.md       # AI-generated topic overview
│   │   ├── equations.md         # Key equations reference
│   │   ├── exam-prep.md         # Practice questions
│   │   ├── flashcards.md        # Quick review cards
│   │   └── weak-areas.md        # Topics to focus on
│   └── your-subject/            # Create as many as you need
├── setup/
│   ├── README.md                # Full setup guide
│   ├── claude-desktop-config.example.json  # MCP config template
│   └── feynman.md               # Feynman research agent guide
├── scripts/
│   ├── new-subject.sh           # Create a subject from template
│   └── build-reference.sh       # Trigger reference generation
├── templates/
│   └── exam-prep.tex            # LaTeX template for exam prep notes
├── desktop-instructions-template.md  # Claude Desktop project instructions
├── CLAUDE.md                    # Instructions for Claude Code
└── README.md                    # This file
```

### Adding a subject

**Option 1:** Use the script
```bash
bash scripts/new-subject.sh "Organic Chemistry"
```

**Option 2:** Copy the template manually
```bash
cp -r subjects/_template subjects/organic-chemistry
```

**Option 3:** Just create the folder
```bash
mkdir -p subjects/organic-chemistry/materials
# Drop PDFs in, Claude figures out the rest
```

---

## Slash Commands (Claude Code)

| Command | What it does |
|---------|-------------|
| `/init-session` | Scan all materials, build indexes, set exam dates |
| `/why [question]` | Direct answer with source citations |
| `/big-picture` | Extract every equation, definition, theorem |
| `/past-papers` | Analyze exam patterns and frequency |
| `/diagnose` | Find your weak areas and knowledge gaps |
| `/drill [topic]` | Active recall — Claude asks, you answer |
| `/flash [topic]` | Rapid-fire flashcards |
| `/mock-exam` | Generate a practice exam |
| `/weekly-plan` | Structured 7-day study plan |
| `/where-i-am` | Progress dashboard |
| `/i-am-fucked` | Emergency mode — what to study with minimal time |
| `/latex-notes [subject]` | Generate professional LaTeX exam prep notes |
| `/paperman [subject]` | Concepts & definitions → formatted PDF reference |
| `/deepresearch [topic]` | Multi-agent cited research via Feynman |
| `/review` | Daily spaced repetition review session |
| `/cant-be-arsed` | Auto-organize downloaded course files |

---

## Feynman Research Integration

[Feynman](https://github.com/getcompanion-ai/feynman) adds multi-agent research capabilities to your study workflow:

```
Lead Agent (plans, delegates, synthesizes)
  ├── Researcher (evidence gathering — papers, web, repos)
  ├── Reviewer (adversarial audit — catches unsupported claims)
  ├── Writer (structured drafting from research notes)
  └── Verifier (citation checking, dead link cleanup)
```

### What it gives you

- **Cited sources** — every claim has a URL or reference
- **Adversarial verification** — a reviewer agent checks for unsupported claims
- **Provenance tracking** — `.provenance.md` sidecar shows what was consulted, accepted, rejected
- **Multi-angle research** — 3-6 researchers investigate different dimensions simultaneously

### Study-specific commands

```bash
# Deep dive before an exam
/deepresearch "Nyquist stability criterion — derivation, intuition, exam pitfalls"

# Compare methods from your course
feynman compare "Jacobi vs Gauss-Seidel vs SOR for linear systems"

# Literature review for a dissertation
feynman lit "dynamic phasor simulation methods for power systems"

# Check your study notes against sources
feynman review subjects/numerical-analysis/big-picture.md
```

Full reference: [`setup/feynman.md`](setup/feynman.md)

---

## Supported File Types

| Type | Status |
|------|--------|
| `.pdf` | Full support — Claude reads text and images |
| `.md` | Full support |
| `.txt` | Full support |
| `.png`, `.jpg` | Full support — diagrams, handwritten notes, photos |
| `.pptx`, `.docx` | Not supported — convert to PDF first |

---

## LaTeX Exam Prep Notes

Generate publication-quality revision documents from your study materials:

```bash
/latex-notes numerical-analysis              # All topics
/latex-notes numerical-analysis "part 2"     # Specific part
/latex-notes EE301 weeks 1-3                 # Week range
```

Claude reads your materials and produces a `.tex` file with:
- Precise definitions, every equation boxed, variable definitions
- TikZ diagrams and circuit schematics (where applicable)
- Worked examples with varied numbers
- Comparison tables, derivations, common mistakes
- Summary section and self-test checklist

### Paperman — One-Command PDF Reference

`/paperman` goes further: it organises your entire subject into a polished, print-ready PDF with a title page, table of contents, colour-highlighted key equations, exam tips, and self-test checklists.

```bash
/paperman numerical-analysis                 # Full subject reference
/paperman numerical-analysis part 3          # Just one part
/paperman EE301 "circuit analysis"           # Focused topic
```

Output lands in `<subject>/paperman/` as both `.tex` and compiled `.pdf`.

---

## Good Prompts to Try

### Understanding concepts
- *"Explain [concept] using an analogy"*
- *"Walk me through [topic] from first principles"*
- *"What's the intuition behind [equation]?"*
- *"Compare and contrast [A] and [B]"*

### Building references
- *"Build big picture for [subject]"*
- *"List all equations from [subject] with explanations"*
- *"Create a cheat sheet for [topic]"*

### Active study
- *"Quiz me on [topic]"*
- *"Give me 10 flashcards for [subject]"*
- *"Practice problems: [topic], medium difficulty"*
- *"Explain what I got wrong and why"*

### Exam prep
- *"Analyze my past papers and find patterns"*
- *"What topics should I prioritise?"*
- *"Mock exam for [subject], 2 hours, past paper style"*
- *"I have 3 days until my exam — what should I focus on?"*

### Deep research
- *"/deepresearch [complex topic]"*
- *"Research [topic] from multiple angles with citations"*
- *"Compare [method A] vs [method B] with sources"*

---

## Tips

- **Organise by week** if you can: `materials/week-01/`, `materials/week-02/`, etc.
- **Include past papers** in your materials folder. Claude will analyze them and predict what's likely to appear.
- **Use symlinks** if your files live elsewhere:
  ```bash
  ln -s ~/Documents/My-Course-Slides subjects/my-course/materials
  ```
- **Multiple subjects** work great together — Claude can spot connections between them.

---

## Privacy

All data stays on your machine. Materials are never uploaded anywhere. Claude reads files locally through Claude Desktop's file access or Claude Code's filesystem tools.

## License

MIT
