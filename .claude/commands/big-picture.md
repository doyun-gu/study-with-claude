Extract every equation, definition, theorem, and key concept from all module materials.

## Instructions

### Step 1: Load Materials

Read `.study/context.md` for the full material inventory. Then read the actual source files for each module — not just summaries, the real content.

For large PDFs, read 20 pages at a time systematically.

### Step 2: Extract Per Module and Week

For each module, for each week, extract:

1. **Equations** — Every mathematical formula, in LaTeX format
   - Include the equation name/label if given
   - Note what each variable represents
   - Note when/where to use each equation

2. **Definitions** — Formal definitions of key terms
   - Use the exact wording from the source material
   - Note the source (file, page)

3. **Theorems / Laws / Principles** — Named results
   - Statement of the theorem
   - Key conditions/assumptions
   - Common applications

4. **Important Constants** — Physical constants, standard values
   - Symbol, value, units

5. **Concept Relationships** — How concepts connect
   - Prerequisites (concept A requires understanding of B)
   - Applications (concept A is used to derive/prove B)
   - Equivalences (concept A in Module X = concept B in Module Y)

### Step 3: Organize Hierarchically

Structure as: **Module > Topic > Week**

Group related equations and concepts by topic, not just by week of appearance. A topic may span multiple weeks.

### Step 4: Cross-Module Connections

Build a cross-module connections table:

| Concept | Module A | Module B | Relationship |
|---------|----------|----------|--------------|
| Complex numbers | MATH201 week-03 | EE301 week-05 | Phasor representation uses complex arithmetic |

### Step 5: Generate Big Picture File

Write `.study/big-picture.md`:

```markdown
---
generated: YYYY-MM-DD
modules: [list]
total_equations: N
total_definitions: N
---

# Big Picture — Complete Concept Reference

## [Module Name]

### [Topic 1]
**Source:** week-NN

#### Equations
| # | Equation | Name | When to Use |
|---|----------|------|-------------|
| 1 | $$V = IR$$ | Ohm's Law | Relates voltage, current, and resistance in linear circuits |

**Variable Definitions:**
- $V$ — voltage (V)
- $I$ — current (A)
- $R$ — resistance (Ω)

#### Definitions
- **[Term]:** [Definition] *(Source: week-NN/file.pdf, p.X)*

#### Theorems & Laws
- **[Theorem Name]:** [Statement]. Conditions: [conditions]. *(Source: ...)*

#### Key Constants
| Constant | Symbol | Value | Units |
|----------|--------|-------|-------|
| ... | ... | ... | ... |

### [Topic 2]
...

---

## Cross-Module Connections

| Concept | Where | Related To | Relationship |
|---------|-------|------------|--------------|
| [concept] | [Module, Week] | [Module, Week] | [how they relate] |

---

## Concept Map Summary

[Brief narrative connecting the major themes across all modules — how everything fits together]
```

### Step 6: Terminal Summary + Browser Render

**Terminal (5-10 lines only):**
- Equations / definitions / theorems count per module (one line per module)
- Number of cross-module connections found
- Any gaps (topics with no equations/definitions)

**Then render in browser:**
```bash
bash .study-tools/render.sh .study/big-picture.md
```

End with:
```
Full reference: .study/big-picture.md | Rendered view opened in browser
```

### Important

- Be thorough. This is the student's master reference. Don't skip equations because they seem minor.
- Always include variable definitions with equations — an equation without context is useless.
- Use exact notation from the source material. Don't change variable names.
- Back-reference everything to source files and pages for easy lookup.
