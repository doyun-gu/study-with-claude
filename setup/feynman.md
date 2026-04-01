# Feynman Research Agent — Study Integration

[Feynman](https://github.com/getcompanion-ai/feynman) is an open-source multi-agent research tool that automates deep academic and technical research with source-grounded, cited outputs.

study-with-claude integrates Feynman to give students access to rigorous, cited research — not LLM hallucinations.

---

## Why Use It for Studying

| Problem | How Feynman helps |
|---------|-------------------|
| Need to understand a complex concept deeply | Multi-agent parallel research from multiple angles |
| Want cited sources, not hand-wavy explanations | Every claim has a URL or citation |
| Studying from conflicting sources | Adversarial reviewer agent checks for unsupported claims |
| Preparing a dissertation or research project | Literature review with consensus/gap analysis |
| Comparing methods or approaches | Side-by-side comparison matrix with sources |

---

## Architecture

```
Lead Agent (plans, delegates, synthesizes)
  |
  +-- Researcher (evidence gathering — papers, web, repos)
  +-- Reviewer (adversarial audit, peer review simulation)
  +-- Writer (structured drafting from research notes)
  +-- Verifier (inline citation, URL verification, dead link cleanup)
```

Agents communicate via file-based handoffs. Each subagent writes output to a file and passes back a lightweight reference.

### Deep Research Pipeline

```
Plan (strategy + acceptance criteria)
  → Scale Decision (how many researchers to spawn)
  → Spawn Parallel Researchers (disjoint dimensions)
  → Evaluate & Loop (check gaps, spawn more if needed)
  → Write Report (structured brief with charts/diagrams)
  → Cite (inline citations, numbered sources)
  → Verify (adversarial audit for unsupported claims)
  → Deliver (final .md + .provenance.md sidecar)
```

---

## Installation

```bash
# Install Feynman
curl -fsSL https://feynman.is/install | bash

# First-time setup (interactive — sets API keys)
feynman setup

# Verify
feynman doctor
```

### API Keys

Set in `~/.feynman/.env` or your shell environment:

```bash
# Choose one model provider
FEYNMAN_MODEL=anthropic/claude-sonnet-4    # recommended
# FEYNMAN_MODEL=openai/gpt-4o             # alternative

FEYNMAN_THINKING=medium                     # low | medium | high

# API key for your chosen provider
ANTHROPIC_API_KEY=sk-ant-...
# OPENAI_API_KEY=sk-...
```

---

## Commands

### Research Workflows

| Command | What It Does | When to Use |
|---------|-------------|-------------|
| `/deepresearch` | Multi-round, multi-agent investigation | Complex topics, exam prep deep dives |
| `feynman lit` | Literature review with consensus/gap analysis | Dissertations, research projects |
| `feynman review` | Simulated peer review with severity annotations | Check your own notes or reports |
| `feynman compare` | Source comparison matrix | Evaluating competing methods |
| `feynman draft` | Paper-style document from research | Writing up findings |
| `feynman audit` | Paper vs notes mismatch check | Verify your understanding matches sources |

### Utility Commands

```bash
feynman model list          # available models
feynman model set <model>   # switch model
feynman packages list       # installed packages
feynman update              # self-update
```

---

## Study Patterns

### Pattern 1: Deep Concept Understanding

Before an exam, research a hard topic from multiple angles:

```bash
/deepresearch "Nyquist stability criterion — derivation from Cauchy's argument principle, graphical interpretation, gain and phase margin, common exam question patterns"
```

Output: a comprehensive, cited brief covering every angle — better than any single textbook.

### Pattern 2: Method Comparison

When your course covers multiple approaches:

```bash
feynman compare "Newton-Raphson vs bisection vs secant method — convergence rate, stability, computational cost, when to use each"
```

Output: a comparison matrix with sources showing exactly when each method is preferred.

### Pattern 3: Literature Review (Dissertation/Project)

```bash
feynman lit "machine learning approaches to power system state estimation — methods, accuracy, computational requirements"
```

Output: structured review with consensus findings, gaps in current research, and numbered citations.

### Pattern 4: Verify Your Understanding

Run a peer review on your own study notes:

```bash
feynman review subjects/numerical-analysis/big-picture.md
```

Output: severity-annotated feedback — what's correct, what's missing, what's wrong.

### Pattern 5: Recurring Monitoring

Track new publications in your research area:

```bash
feynman watch "new publications on browser-based engineering simulation tools" --interval weekly
```

---

## Output Files

Research outputs are created in your working directory:

```
./outputs/
  ├── topic-name.md              # Final research report
  ├── topic-name.provenance.md   # Source tracking sidecar
  └── .plans/                    # Research plans (intermediate)
```

The `.provenance.md` sidecar shows what was consulted, accepted, and rejected — full audit trail.

---

## Integration with study-with-claude

The `/deepresearch` slash command in Claude Code wraps Feynman for study-specific use:

1. Takes your study question
2. Runs Feynman's multi-agent research pipeline
3. Saves output to your subject's folder
4. Updates your `.study/` state files with new knowledge

You can also delegate research from Claude Desktop by creating a task:
```
"Research [topic] deeply" → creates a deepresearch task for Claude Code
```

---

## Key Packages (Pi Ecosystem)

| Package | Purpose |
|---------|---------|
| `@companion-ai/alpha-hub` | AlphaXiv paper search, Q&A, code reading |
| `pi-web-access` | Web search (Perplexity or Gemini) |
| `pi-subagents` | Multi-agent orchestration |
| `pi-zotero` | Zotero reference manager integration |
| `@walterra/pi-charts` | Chart generation |
| `pi-mermaid` | Mermaid diagram rendering |

---

## Skills-Only Install

If you already have a compatible agent shell:

```bash
curl -fsSL https://feynman.is/install-skills | bash
```
