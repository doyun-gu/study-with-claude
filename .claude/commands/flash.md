Rapid-fire flashcard session for memorizing equations, definitions, and key facts.

Arguments: $ARGUMENTS
(Optional: module, card type, card count — e.g., "EE301", "equations", "definitions", "10")

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Module filter:** If a module name is given, limit cards to that module
- **Card type filter:** "equations" (equations only), "definitions" (definitions only). If not specified, mix both.
- **Card count:** If a number is given (1-20), use it. Default: 5

Examples:
- `/flash` → auto-select cards, 5 cards
- `/flash EE301` → EE301 only, 5 cards
- `/flash equations` → equations only across all modules, 5 cards
- `/flash definitions` → definitions only, 5 cards
- `/flash 10` → auto-select, 10 cards
- `/flash EE301 equations 10` → EE301 equations, 10 cards

### Step 2: Load State

Read:
- `.study/big-picture.md` — **primary source** for equations, definitions, concepts
- `.study/diagnosis.md` — weak areas (if exists)
- `.study/past-paper-analysis.md` — exam topic frequencies (if exists)
- `.study/flash-log.md` — previous flashcard sessions, intervals, inventory (if exists)
- `.study/progress.md` — exam dates

If `.study/big-picture.md` doesn't exist:
> "No equations or definitions extracted yet. Run `/big-picture` first to build your concept inventory, then come back for flashcards."

Stop here.

### Step 3: Select Cards

Build the card pool from `big-picture.md` content, then select cards using this priority:
1. **Due for review today:** Cards in `flash-log.md` with `next_review` ≤ today
2. **Poor drill performance:** Topics that scored 0 or 1 in `drill-log.md` (if exists) — pull related equations/definitions
3. **High exam-frequency items not yet memorized:** Equations/definitions for topics in `past-paper-analysis.md` that aren't in `flash-log.md`
4. **Weak areas:** Items related to topics in `diagnosis.md`
5. **New cards:** Items from `big-picture.md` not yet in `flash-log.md`

### Step 4: Card Types

Each card has a **front** (prompt) and **back** (answer). Card types:

- **Equation recall:** Front = equation name or description. Back = the equation in ASCII math.
  - Example: Front: "Ohm's Law" → Back: "V = I × R"
- **Definition recall:** Front = term. Back = precise definition.
  - Example: Front: "Impedance" → Back: "Total opposition to AC current flow, Z = R + jX, measured in ohms"
- **Variable identification:** Front = equation. Back = what each symbol means.
  - Example: Front: "P = V × I × cos(φ)" → Back: "P = real power (W), V = voltage (V), I = current (A), φ = phase angle between V and I"
- **"When to use":** Front = equation or method name. Back = the application context.
  - Example: Front: "When do you use Thevenin's theorem?" → Back: "To simplify a complex circuit into a single voltage source and series resistance, seen from two terminals. Use when analyzing load variations."

### Step 5: Interactive Flashcard Loop

For each card:

1. **Show the card front:**
   ```
   ─── Card 1/5 ───────────────────────
   [Card type: Equation Recall]

   What is the equation for [concept]?
   ────────────────────────────────────
   ```
2. **Wait for the student's answer.**
3. **Reveal the correct answer:**
   ```
   ─── Answer ─────────────────────────
   [Correct answer in ASCII math]

   Source: [Module] week-NN
   ────────────────────────────────────
   ```
4. **Ask the student to self-rate:**
   > Rate yourself: **1** (wrong/blank), **2** (got it but it was hard), **3** (easy/instant recall)
5. **Wait for rating, then move to next card.**

### Step 6: Session Summary

After all cards:

```
╔═══════════════════════════════════════╗
║         FLASHCARD RESULTS            ║
╠═══════════════════════════════════════╣
║  Cards reviewed: N                    ║
║  Retention: N% (rated 2 or 3)       ║
║                                       ║
║  Easy (3):  N cards                   ║
║  Hard (2):  N cards                   ║
║  Wrong (1): N cards                   ║
║                                       ║
║  Due tomorrow: N cards                ║
║  Due this week: N cards               ║
╚═══════════════════════════════════════╝
```

### Step 7: Update State Files

**Write/update `.study/flash-log.md`:**

If the file doesn't exist, create it:

```markdown
---
total_sessions: N
total_reviews: N
retention_rate: N%
last_session: YYYY-MM-DD
---

# Flashcard Log

## Card Inventory

| Card ID | Type | Front (short) | Module | Ease | Interval | Next Review | Reviews |
|---------|------|---------------|--------|------|----------|-------------|---------|
| eq-001 | equation | Ohm's Law | EE301 | 2.5 | 7d | YYYY-MM-DD | 3 |
| def-001 | definition | Impedance | EE301 | 1.8 | 1d | YYYY-MM-DD | 5 |

## Session History

### YYYY-MM-DD
- Cards: N | Retention: N%
- Easy: N | Hard: N | Wrong: N
- New cards added: N
```

**Spaced repetition scheduling:**

Each card tracks an `ease` factor (starts at 2.5) and an `interval` (in days):

- **Rating 1 (wrong):** interval = 1 day, ease = max(1.3, ease - 0.2)
- **Rating 2 (hard):** interval = max(3, current interval × 1.2), ease unchanged
- **Rating 3 (easy):** interval = max(7, current interval × ease), ease = min(3.0, ease + 0.1)
- **New card first review:** Rating 1 → 1 day, Rating 2 → 3 days, Rating 3 → 7 days

`next_review` = today + interval

**Update `.study/progress.md`:**
- Add session log entry: "YYYY-MM-DD: Flashcard session — N cards, N% retention"

### Important

- **Cards come from the student's materials.** Every equation and definition must trace back to `big-picture.md` which traces back to their lecture content.
- **ASCII math only in terminal.** Use `V = IR` not `$V = IR$`. Use `Z = R + jX` not LaTeX.
- **One card at a time.** Don't show all cards at once. The recall attempt before seeing the answer is the entire point.
- **Self-rating is mandatory.** Don't skip the rating step — it drives the spaced repetition algorithm.
- **Be honest about retention.** Only ratings of 2 or 3 count as "retained." Rating 1 = not retained.
- **Card IDs are stable.** If a card already exists in `flash-log.md`, update it rather than creating a duplicate. Use the format `eq-NNN` for equations, `def-NNN` for definitions, `var-NNN` for variable cards, `use-NNN` for "when to use" cards.
- **Terminal only.** 5-10 lines for the summary. No auto-render.
