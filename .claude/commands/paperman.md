Organise concepts, definitions, and equations from study materials into a beautifully formatted LaTeX document and compile it to PDF.

Arguments: $ARGUMENTS
(Required: subject name or topic. Optional: scope like "part 1", "weeks 1-3", "all")

## What This Does

Paperman reads your materials, extracts every concept, definition, and equation, organises them logically by topic, and produces a **print-ready PDF** — not just a `.tex` file. The output goes straight into your subject folder, ready to revise from.

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Subject:** Match against `subjects/` directories or top-level module directories
- **Scope:** `"all"` (default), `"part N"`, `"weeks N-M"`, or a specific topic name
- **Output dir:** Defaults to `<subject>/paperman/`

Examples:
- `/paperman numerical-analysis` → full subject, all topics
- `/paperman numerical-analysis part 3` → just part 3
- `/paperman EE301 "circuit analysis"` → focused document
- `/paperman EE301 weeks 1-5` → first five weeks

If no subject is given, ask the student which subject to use.

### Step 2: Load and Inventory Materials

1. Read `.study/content-index.md` and `.study/big-picture.md` if they exist — these are pre-extracted inventories.
2. Read `.study/file-map.md` to understand material structure.
3. Read the actual source materials for the target scope. For large PDFs, read 20 pages at a time.
4. Read `.study/past-paper-analysis.md` if it exists — mark frequently-examined topics.

**If `.study/` files don't exist:** fall back to reading all materials in the subject directory directly.

### Step 3: Extract and Organise Content

Build a structured outline before writing any LaTeX. Group into logical topic areas:

For each topic, extract:
1. **Definitions** — every key term with precise wording from the source
2. **Equations** — every formula with variable definitions
3. **Derivations** — step-by-step derivations students must reproduce
4. **Relationships** — how concepts connect, prerequisites, applications
5. **Comparison points** — when there are multiple methods/types to compare
6. **Worked examples** — from lecture materials (vary numbers from originals)
7. **Common mistakes** — pitfalls students typically fall into
8. **Exam notes** — frequency in past papers, typical question format

Organise by **conceptual flow** (foundations → core theory → applications → advanced), not chronologically by week.

### Step 4: Design the Document

The document should feel like a **polished reference handbook**, not lecture notes. Design choices:

**Title page:** Include subject name, code, scope covered, date generated, and a brief contents overview.

**Table of contents:** Auto-generated from sections.

**Visual hierarchy:**
- Major topics as `\section*{}`
- Sub-topics as `\subsection*{}`
- Definitions in a consistent `\textbf{Term:}` pattern with nested itemize
- Key equations boxed: `\boxed{}`
- Supporting equations in display math without box
- Comparison tables using booktabs
- Diagrams in TikZ/circuitikz where possible
- Worked examples clearly separated with Given/Find/Solution structure
- Exam-relevant topics marked with a margin note or bold annotation

### Step 5: Write the LaTeX

Use this exact preamble — do NOT deviate:

```latex
\documentclass[11pt,a4paper]{article}

\usepackage[margin=2cm]{geometry}
\usepackage{amsmath,amssymb}
\usepackage{enumitem}
\usepackage{booktabs}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{tikz}
\usepackage[siunitx]{circuitikz}
\usetikzlibrary{arrows.meta,positioning,decorations.pathreplacing}
\usepackage{xcolor}
\usepackage{tcolorbox}
\usepackage{hyperref}

% ── Header / Footer
\pagestyle{fancy}
\fancyhf{}
\lhead{<MODULE-CODE> <Module Name>}
\rhead{Concepts \& Definitions Reference}
\cfoot{\thepage}

% ── Section Formatting
\titleformat{\section}{\Large\bfseries\itshape}{}{0em}{}[\vspace{-0.5em}\rule{\textwidth}{0.4pt}]
\titleformat{\subsection}{\large\bfseries}{}{0em}{}
\titleformat{\subsubsection}{\normalsize\bfseries\itshape}{}{0em}{}
\setlength{\parindent}{0pt}
\setlength{\parskip}{4pt}

% ── Custom environments
\newtcolorbox{keyeq}{colback=blue!3, colframe=blue!40, boxrule=0.5pt, arc=2pt, left=6pt, right=6pt, top=4pt, bottom=4pt}
\newtcolorbox{examtip}{colback=red!3, colframe=red!40, boxrule=0.5pt, arc=2pt, left=6pt, right=6pt, top=4pt, bottom=4pt, title={\small\textbf{Exam Tip}}}
```

#### Formatting Rules (non-negotiable)

1. **Sections:** Always `\section*{}` and `\subsection*{}` (unnumbered)
2. **Section separators:** `% ══════════════════════════════════════════════════════════════` between major sections
3. **Primary lists:** `\begin{itemize}[leftmargin=1.5em, itemsep=2pt]`
4. **Nested lists:** `\begin{itemize}[leftmargin=1em, itemsep=1pt]`
5. **Definition pattern:** `\item \textbf{Term:}` followed by definition text
6. **Key equations:** Use the `keyeq` environment for the most important equations:
   ```latex
   \begin{keyeq}
   \[ F = ma \]
   where $F$ is force (N), $m$ is mass (kg), $a$ is acceleration (m/s$^2$).
   \end{keyeq}
   ```
7. **Supporting equations:** Display math `\[ \]` with `\boxed{}` for moderate importance, plain for derivation steps
8. **Tables:** Booktabs with `\renewcommand{\arraystretch}{1.2}`
9. **Diagrams:** TikZ for block diagrams, circuitikz for circuits. Blue for input/signal, red for output/emphasis
10. **Worked examples:** `\subsection*{Example: <description>}` with `\textbf{Given:}`, `\textbf{Find:}`, `\textbf{Solution:}` structure. Bold final answers with `\mathbf{}`
11. **Units:** Thin space before units: `5\,\text{V}`, `100\,\Omega`
12. **Exam tips:** Use the `examtip` environment for past-paper insights:
    ```latex
    \begin{examtip}
    This topic appeared in 4/5 recent papers. Typical format: derive the equation, then apply to a numerical example.
    \end{examtip}
    ```
13. **Cross-references:** `(see \S\ref{sec:topic} for ...)` or `(compare with ...)`
14. **Checklist:** End each major section with `\item[$\square$]` self-test items

### Step 6: Write the Title Page

```latex
\begin{titlepage}
\centering
\vspace*{3cm}
{\Huge\bfseries <Module Name>\par}
\vspace{0.5cm}
{\Large <MODULE-CODE>\par}
\vspace{1.5cm}
{\LARGE Concepts \& Definitions Reference\par}
\vspace{0.3cm}
{\large <Scope covered>\par}
\vspace{2cm}
{\large Generated: \today\par}
\vspace{1cm}
\rule{0.6\textwidth}{0.4pt}
\vspace{0.5cm}

{\normalsize\textit{Auto-generated from course materials using study-with-claude}}
\end{titlepage}

\tableofcontents
\newpage
```

### Step 7: Save the File

Create the output directory and write the `.tex` file:

```
<subject>/paperman/<CODE>-concepts-<scope-slug>.tex
```

Examples:
- `subjects/numerical-analysis/paperman/NA-concepts-all.tex`
- `subjects/numerical-analysis/paperman/NA-concepts-part3.tex`
- `EE301/paperman/EE301-concepts-circuit-analysis.tex`

### Step 8: Compile to PDF

Compile the document. Run pdflatex twice for table of contents:

```bash
cd <output-dir> && pdflatex -interaction=nonstopmode <filename>.tex && pdflatex -interaction=nonstopmode <filename>.tex
```

**If compilation fails:**
1. Read the `.log` file to identify the error
2. Fix the LaTeX source (common issues: unescaped `%`, `&`, `$`, `#`, `_`; missing packages; mismatched braces)
3. Recompile
4. If it still fails after 2 attempts, save the `.tex` file and tell the student what went wrong

**After successful compilation**, clean up auxiliary files:
```bash
rm -f <filename>.aux <filename>.log <filename>.out <filename>.toc
```

### Step 9: Terminal Output

**Terminal (8-12 lines):**
```
── paperman ─────────────────────────────────
Subject:      <name> (<code>)
Scope:        <what was covered>
Sections:     <N> major topics
Definitions:  <N> terms defined
Equations:    <N> equations (<M> key, <K> supporting)
Examples:     <N> worked examples
Exam tips:    <N> annotations from past papers
─────────────────────────────────────────────
PDF:  <path>.pdf
TeX:  <path>.tex
```

If compilation failed:
```
⚠ Compilation failed — .tex saved, fix needed.
   Error: <one-line description>
   TeX:  <path>.tex
```

### Step 10: Update State

Update `.study/progress.md`:
- Note that paperman reference was generated for this subject/scope
- Update `last_session` date

### Important

- **Be exhaustive.** This is the student's definitive reference. Missing a definition or equation could cost exam marks. Extract everything from the source material.
- **Organise by concept, not by week.** Group related content together even if it was taught across different weeks.
- **Variable definitions with every equation.** An equation without defined variables is useless for revision.
- **Use exact notation from the source.** Don't rename variables or change conventions the lecturer used.
- **Verify worked examples.** Check the arithmetic. If you vary numbers from the original, make sure the answer is still clean.
- **The PDF must compile.** This is the whole point — the student gets a ready-to-print document. If you can't compile, fix it. Don't leave a broken `.tex` file.
- **For very large subjects** (>15 pages of output), split into multiple documents by topic area and generate a master document that inputs them. Use `\input{<file>}` pattern.
