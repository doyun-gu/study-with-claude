Generate a professional LaTeX exam prep document from study materials.

Arguments: $ARGUMENTS
(Required: subject or topic. Optional: part/week number, output filename)

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Subject:** Which subject's materials to use. Match against directory names in `subjects/` or top-level module directories.
- **Topic/Part:** Specific topic, part number, or week range to cover (e.g., "part 1", "weeks 1-3", "strain gauge")
- **Output path:** Optional custom filename. Default: `<subject>/exam-prep/<topic-slug>.tex`

Examples:
- `/latex-notes numerical-analysis` → all topics, one file per major topic area
- `/latex-notes numerical-analysis part 2` → just part 2 topics
- `/latex-notes numerical-analysis "error analysis"` → focused on error analysis topic
- `/latex-notes EE301 weeks 1-3` → first three weeks of EE301

If no subject is given, use the subject with the nearest exam date from `.study/progress.md`.

### Step 2: Load Sources

Read in this order:
1. `.study/content-index.md` — find exact file+page locations for the target topic(s)
2. `.study/big-picture.md` — get the full equation/definition inventory
3. `.study/file-map.md` — understand material structure
4. The actual source materials (PDFs, markdown) — read the identified pages. For large PDFs, read 20 pages at a time.
5. `.study/past-paper-analysis.md` (if it exists) — to prioritize exam-relevant content

If `.study/` files don't exist, fall back to reading all materials in the subject directory.

### Step 3: Design the Document Structure

Plan the `.tex` file structure before writing. For each topic section, decide:

1. **Core Definitions** — every key term with precise definitions
2. **Key Equations** — every formula, boxed, with variable definitions and context
3. **Theory / Derivations** — step-by-step derivations the student needs to reproduce
4. **Comparison Tables** — when there are multiple methods, types, or approaches
5. **Diagrams** — TikZ block diagrams for systems/signal flow, circuitikz for circuits
6. **Worked Examples** — from lecture materials with varied numbers
7. **Summary** — concise takeaways with the most important facts
8. **Checklist** — self-test items the student should be able to do from memory

Not every section needs all of these. Include what the content demands.

### Step 4: Write the LaTeX Document

Use this exact preamble and formatting. Do NOT deviate from these conventions:

```latex
\documentclass[11pt,a4paper]{article}

% ── Layout
\usepackage[margin=2cm]{geometry}

% ── Maths
\usepackage{amsmath,amssymb}

% ── Lists & Tables
\usepackage{enumitem}
\usepackage{booktabs}

% ── Headers / Sections
\usepackage{fancyhdr}
\usepackage{titlesec}

% ── Diagrams
\usepackage{tikz}
\usepackage[siunitx]{circuitikz}
\usetikzlibrary{arrows.meta,positioning,decorations.pathreplacing}

% ── Header / Footer
\pagestyle{fancy}
\fancyhf{}
\lhead{<MODULE-CODE> <Module Name> --- <Topic/Part>}
\rhead{<Student Name>}
\cfoot{\thepage}

% ── Section Formatting
\titleformat{\section}{\large\bfseries\itshape}{}{0em}{}
\titleformat{\subsection}{\normalsize\bfseries}{}{0em}{}
\setlength{\parindent}{0pt}
\setlength{\parskip}{4pt}
```

#### Formatting Rules

These are non-negotiable. Follow them exactly:

1. **Sections:** Always `\section*{}` and `\subsection*{}` (unnumbered, starred)
2. **Section separators:** Use `% ══════════════════════════════════════════════════════════════` between major sections
3. **Primary lists:** `\begin{itemize}[leftmargin=1.5em, itemsep=2pt]`
4. **Nested lists:** `\begin{itemize}[leftmargin=1em, itemsep=1pt]`
5. **Definition pattern:** `\item \textbf{Term:}` followed by definition text
6. **Key equations:** Wrap in `\boxed{}` inside display math `\[ \boxed{...} \]`
7. **Supporting equations:** Display math without box `\[ ... \]`
8. **Tables:** Always use booktabs (`\toprule`, `\midrule`, `\bottomrule`) with `\renewcommand{\arraystretch}{1.2}`
9. **Diagrams:** TikZ for block diagrams, circuitikz for electrical circuits. Use color: blue for input/signal, red for output/emphasis
10. **Worked examples:** Bold final answers with `\mathbf{}`. Multi-part use `\item[(i)]`, `\item[(ii)]` pattern
11. **Units:** Use thin space before units: `5\,\text{V}`, `100\,\Omega`, `25\,\mu\text{m}`
12. **Clarifications:** `\textit{italic text}` for notes and caveats
13. **Checklist items:** `\item[$\square$]` for self-test checkboxes
14. **Em-dashes:** Use `---` (three hyphens) in LaTeX text, not Unicode em-dash

### Step 5: Content Quality Rules

1. **Be exhaustive on definitions and equations.** This is exam prep — missing an equation could cost marks. Extract everything from the source material.
2. **Include variable definitions** with every equation. An equation without context is useless.
3. **Use exact notation from the source material.** Don't rename variables or change conventions.
4. **Add exam context.** If a topic appears frequently in past papers (check `.study/past-paper-analysis.md`), note it: `\textit{Frequently examined --- appears in 4/5 past papers.}`
5. **Worked examples must have different numbers** from the lecture materials but the same structure. Verify arithmetic.
6. **Derivations:** Show every step. If the student needs to reproduce it in an exam, don't skip intermediate steps.
7. **Common mistakes:** Note them where relevant: `\textbf{Common mistake:} ...`
8. **Cross-references:** Link related topics: `(see Part X for ...)` or `(compare with ...)`

### Step 6: Write the File

Create the output directory if it doesn't exist:
```
<subject>/exam-prep/<filename>.tex
```

For subjects in `subjects/`:
```
subjects/<subject>/exam-prep/<filename>.tex
```

Naming convention: `<CODE>-<topic-slug>.tex`
- Example: `SAI-part1-fundamentals.tex`
- Example: `NA-error-analysis.tex`
- Example: `EDS-vf-control.tex`

### Step 7: Compile (Optional)

If `pdflatex` is available, offer to compile:
```bash
cd <output-dir> && pdflatex <filename>.tex
```

If compilation fails, diagnose and fix the LaTeX error. Common issues:
- Missing packages (suggest `tlmgr install <package>`)
- Unescaped special characters (`%`, `&`, `$`, `#`, `_`)
- Mismatched braces or environments

### Step 8: Terminal Output

**Terminal (5-10 lines):**
- Subject, topic, number of sections
- Equations extracted: N
- Definitions extracted: N
- Worked examples included: N
- Output path
- Compilation status (if attempted)

End with:
```
Written to <path>.tex
Compile: cd <dir> && pdflatex <filename>.tex
```

### Step 9: Update State

Update `.study/progress.md`:
- Note that LaTeX notes were generated for this topic
- Update `last_session` date

### Important

- The LaTeX template in `templates/exam-prep.tex` shows the exact formatting. When in doubt, match that file.
- Never use `\begin{equation}` — always use `\[ \]` for display math (unnumbered).
- Never number sections — always use `\section*{}` and `\subsection*{}`.
- For very large topics (>10 pages of content), split into multiple `.tex` files by sub-topic.
- If source materials contain diagrams, recreate them in TikZ where possible. For complex diagrams that can't be reasonably reproduced in TikZ, note: `\textit{Refer to [source], page [N] for diagram.}`
- Always include a Summary section and a Checklist section at the end — these are the most valuable for last-minute revision.
