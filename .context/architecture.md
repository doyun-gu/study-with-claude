# Architecture: study-with-claude

Two-layer system: **slash commands** (`.claude/commands/`) drive study workflows, **`.study/` state files** persist knowledge across sessions. The core optimization is a two-phase content index that eliminates redundant full-material reads — most commands read only the specific pages they need.

---

## Content Index Lookup Pattern

The highest-impact optimization. Two complementary indexes enable targeted reads:

- **`file-map.md`** (forward index): file → page ranges → topics. Maps every source file to topic-coherent page blocks (e.g., `slides.pdf pp.4-11 → Basic circuit elements`).
- **`content-index.md`** (reverse index): topic → file:pages. Alphabetical lookup from concept to exact source locations with type tags (`theory`, `formula`, `theorem+examples`, etc.).

**Lookup flow:** question/topic → `content-index.md` → identified page ranges → read ONLY those pages → answer grounded in source material.

**Commands using index reads:** `/why`, `/drill`, `/mock-exam`, `/i-am-fucked`, `/flash` (indirectly via `big-picture.md`).

**Fallback:** If index files don't exist, commands fall back to full material scans (pre-index behavior).

**Regeneration:** Only `/init-session` (Step 6b-6c) and `/big-picture` (Step 5b) generate these indexes — always from material already in memory during their full scans, so no extra file reads.

---

## Command Dependency Graph

```
Tier 0 (bootstrap)
  └─ init-session ─── generates context.md, file-map.md, content-index.md, progress.md

Tier 1 (independent — each can run after init)
  ├─ why            (content-index → targeted reads)
  ├─ past-papers    (reads exam PDFs directly)
  └─ big-picture    (full material scan, regenerates indexes)

Tier 2 (dependent — better/required after Tier 1)
  ├─ diagnose       (better after past-papers — uses frequency data)
  ├─ drill          (uses content-index + big-picture if available)
  └─ flash          (hard-requires big-picture)

Tier 3 (aggregators — combine multiple state files)
  ├─ review         (requires drill-log or flash-log)
  ├─ mock-exam      (past-paper-analysis + content-index)
  ├─ i-am-fucked    (reads everything, writes cheat-sheet)
  └─ weekly-plan    (progress + diagnosis → structured schedule)

Utilities (no .study/ dependencies)
  └─ timer
```

---

## State File Read/Write Matrix

Every command × every `.study/` file. This eliminates the need to open 14 command files to trace dataflow.

```
Legend: R=read  W=write  RW=read+write  R?=read if exists  R!=hard requirement  -=none

                    ctx  prog  qna  pp-a  bp   diag  cs   wp   fm   ci   dl   fl
init-session         W    RW    -    -     -    -     -    -    W    W    -    -
why                  R?   RW    RW   R?    -    -     -    -    -    R    -    -
past-papers          -    -     -    W     -    -     -    -    -    -    -    -
big-picture          R    -     -    -     W    -     -    -    W    W    -    -
diagnose             R    R     R    R?    R?   W     -    -    -    -    R?   R?
drill                R    RW    RW   R?    R?   R?    -    -    R    R    RW   -
flash                -    RW    -    R?    R!   R?    -    -    -    -    -    RW
review               -    RW    R?   R?    -    R?    -    -    -    -    RW   RW
mock-exam            -    RW    -    R     R?   R?    -    -    R    R    -    -
i-am-fucked          R    R     R    R?    R?   R?    W    -    -    R    -    -
where-i-am           R    RW    R?   -     -    R?    -    -    -    -    R?   R?
weekly-plan          R?   RW    R?   R?    -    R?    -    W    -    -    -    -
notion-update        R    R     R    R?    R?   R?    -    -    -    -    -    -
timer                -    -     -    -     -    -     -    -    -    -    -    -
```

**Columns:** ctx=context.md, prog=progress.md, qna=qna-log.md, pp-a=past-paper-analysis.md, bp=big-picture.md, diag=diagnosis.md, cs=cheat-sheet.md, wp=weekly-plan.md, fm=file-map.md, ci=content-index.md, dl=drill-log.md, fl=flash-log.md

---

## Spaced Repetition Cycle

Four commands form a feedback loop:

1. **`/drill`** — generates questions, grades answers, writes scores to `drill-log.md` with SM-2 interval scheduling
2. **`/flash`** — rapid-fire cards from `big-picture.md`, tracks retention in `flash-log.md` with intervals
3. **`/review`** — daily dispatcher: reads both logs, surfaces items where `next_review ≤ today`, runs a mixed drill+flash session, updates intervals
4. **`/diagnose`** — reads drill-log and flash-log as weakness signals (low scores, failed cards), feeds back into study priorities

**Score → interval mapping (SM-2 variant):** 5=perfect→2× interval, 4=hesitant→1.5×, 3=hard→1×, 2=wrong-then-corrected→0.5×, 1=blank→reset to 1 day.

---

## Rendering Pipeline

`render.sh` enables rich output (LaTeX equations, formatted tables) without terminal limitations:

1. Command writes full content to `.study/` markdown file
2. `bash .study-tools/render.sh [filepath]` base64-encodes the markdown
3. Injects encoded content into `template.html` (MathJax + marked.js renderer)
4. Writes a temp HTML file and auto-opens in default browser

**Auto-render commands:** `/past-papers`, `/big-picture`, `/mock-exam`, `/weekly-plan`, `/i-am-fucked`.
**Terminal-only commands:** `/init-session`, `/why`, `/diagnose`, `/where-i-am`, `/drill`, `/flash`, `/review`.

---

## Auto-Logging Invariant

Any learning interaction updates state — even without explicit commands. If a student asks a question in normal conversation:
- Append to `qna-log.md` (with dedup check, topic tag, priority)
- Update `progress.md` topic coverage
- If a misconception is corrected, bump priority in `qna-log.md`

This ensures `.study/` is always the source of truth for what the student has studied.
