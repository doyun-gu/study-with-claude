Deep research on a study topic using the Feynman multi-agent research pipeline.

## Input

The student provides a topic or question. Examples:
- `/deepresearch Nyquist stability criterion`
- `/deepresearch "Jacobi vs Gauss-Seidel convergence properties"`
- `/deepresearch power factor correction techniques for induction motors`

$ARGUMENTS

## Prerequisites

- Feynman must be installed (`feynman doctor` to check)
- If Feynman is not installed, tell the student: "Feynman research agent is not installed. Run `curl -fsSL https://feynman.is/install | bash` to set it up. See `setup/feynman.md` for details."

## Procedure

### Step 1: Check Feynman availability

```bash
command -v feynman &>/dev/null && echo "FEYNMAN_OK" || echo "FEYNMAN_MISSING"
```

If missing, print setup instructions and stop.

### Step 2: Determine subject context

Read `.study/modules.md` (or `.study/context.md`) to identify which module/subject the topic belongs to. This helps frame the research.

### Step 3: Construct the research prompt

Build a study-focused research prompt:

```
"[TOPIC] — comprehensive study reference covering: core theory and derivation, intuitive explanation, worked examples, common exam question patterns, connections to related topics, and key equations with variable definitions. Target audience: undergraduate engineering student preparing for exams."
```

### Step 4: Run Feynman deep research

```bash
cd [study-directory]
feynman deepresearch "[constructed prompt]"
```

Wait for completion. This may take 2-5 minutes depending on topic complexity.

### Step 5: Process output

1. Read the output file from `./outputs/`
2. Read the `.provenance.md` sidecar for source verification
3. Extract key findings:
   - Core equations (in LaTeX)
   - Key definitions
   - Worked examples
   - Common misconceptions
   - Exam tips

### Step 6: Save to subject folder

If the topic maps to an existing subject:
```
subjects/[subject-name]/research/[topic-slug].md
```

If no matching subject, save to:
```
.study/research/[topic-slug].md
```

Include the provenance sidecar alongside.

### Step 7: Update state files

- Append to `.study/qna-log.md` with `Source: feynman-deepresearch`
- Update `.study/progress.md` topic coverage if the topic maps to a known module

### Step 8: Terminal summary

Print a concise summary (10-15 lines):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Deep Research: [Topic]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Module:     [detected module or "General"]
Sources:    [N] cited references
Key points:
  1. [most important finding]
  2. [second finding]
  3. [third finding]

Key equations:
  - [equation 1 in ASCII]
  - [equation 2 in ASCII]

Saved to: subjects/[subject]/research/[topic].md
Provenance: subjects/[subject]/research/[topic].provenance.md

View full: bash .study-tools/render.sh [path]
```

### If Feynman fails or times out

Fall back to Claude's own knowledge:
1. Note that Feynman was unavailable
2. Provide the best answer possible with clear caveats about uncited claims
3. Suggest the student retry later or run Feynman manually:
   ```bash
   feynman deepresearch "[topic]"
   ```
