Active recall drill — Claude asks questions, student answers, Claude grades understanding.

Arguments: $ARGUMENTS
(Optional: module, topic, question count — e.g., "EE301", "EE301 thevenin", "5", "EE301 5")

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Module filter:** If a module name is given (matches a detected module directory), limit questions to that module
- **Topic filter:** If a second word follows the module name and it's not a number, use it as a topic filter
- **Question count:** If a number is given (1-10), use it as the question count. Default: 3

Examples:
- `/drill` → auto-select topics, 3 questions
- `/drill EE301` → EE301 only, 3 questions
- `/drill EE301 thevenin` → EE301 Thevenin topics only, 3 questions
- `/drill 5` → auto-select topics, 5 questions
- `/drill EE301 5` → EE301 only, 5 questions

### Step 2: Load State

Read:
- `.study/context.md` — module inventory, topics
- `.study/diagnosis.md` — weak areas (if exists)
- `.study/past-paper-analysis.md` — exam topic frequencies (if exists)
- `.study/big-picture.md` — equations, definitions, concepts (if exists)
- `.study/progress.md` — coverage data, exam dates
- `.study/drill-log.md` — previous drill results and review schedule (if exists)

Also read the **actual source material** (lecture slides, notes) for the selected topics. Questions must be grounded in real content, not generic.

### Step 3: Select Questions

Choose questions using this priority order:
1. **Weak areas with high exam frequency:** Topics in `diagnosis.md` that also appear frequently in `past-paper-analysis.md`
2. **Covered but never tested:** Topics the student has studied (in `progress.md`) but never drilled on (not in `drill-log.md`)
3. **Stale high-frequency topics:** Topics last drilled >7 days ago with high exam frequency
4. **Due for review:** Topics whose next review date in `drill-log.md` is today or overdue
5. **General coverage:** Fill remaining slots with topics proportional to exam proximity

### Step 4: Question Types

Mix question types for variety. Each question should be one of:

- **Conceptual:** "Explain why [X] happens" / "What is the physical meaning of [Y]?"
- **Error detection:** "A student says [wrong reasoning]. What's wrong with this?"
- **Application:** "Given [scenario], which method would you use and why?"
- **Derivation prompt:** "Starting from [equation], derive [result]" or "Show the steps to get from [A] to [B]"
- **Prediction:** "If [X] doubles, what happens to [Y]? Explain."
- **Compare/contrast:** "What's the difference between [A] and [B]? When would you use each?"

Questions must reference specific content from the student's materials. Include the source reference (module, week, page) in your internal tracking.

### Step 5: Interactive Drill Loop

For each question:

1. **Present the question** clearly. Include any necessary context (circuit diagram description, given values, etc.)
2. **Wait for the student's answer.** Do not proceed until they respond.
3. **Grade strictly** using this rubric:
   - **2 (Correct):** Answer demonstrates clear understanding. Key concepts, equations, and reasoning are correct. Minor notation issues are fine.
   - **1 (Partial):** Answer shows some understanding but has gaps — missing key steps, incomplete reasoning, correct conclusion with wrong justification, or correct method with calculation errors.
   - **0 (Incorrect):** Fundamental misunderstanding, wrong method, or "I don't know." No partial credit for vague answers.
4. **Provide feedback:**
   - For score 2: Brief confirmation + one extension point ("Correct. Also note that this connects to...")
   - For score 1: Identify what was right, then clearly explain what was missing or wrong
   - For score 0: Give the complete correct answer with reasoning, referencing the source material
5. **Move to the next question.**

### Step 6: Session Summary

After all questions are answered, print a summary:

```
╔═══════════════════════════════════════╗
║           DRILL RESULTS              ║
╠═══════════════════════════════════════╣
║  Score: X/Y (Z%)                     ║
║                                       ║
║  [Topic 1] ............... ██ 2/2    ║
║  [Topic 2] ............... █░ 1/2    ║
║  [Topic 3] ............... ░░ 0/2    ║
║                                       ║
║  Next review:                         ║
║  [Topic 1]: 7 days (YYYY-MM-DD)     ║
║  [Topic 2]: 3 days (YYYY-MM-DD)     ║
║  [Topic 3]: 1 day  (YYYY-MM-DD)     ║
╚═══════════════════════════════════════╝
```

### Step 7: Update State Files

**Write/update `.study/drill-log.md`:**

If the file doesn't exist, create it with this structure:

```markdown
---
total_drills: N
total_questions: N
average_score: N%
last_drill: YYYY-MM-DD
---

# Drill Log

## Review Schedule

| Topic | Module | Last Score | Last Drilled | Next Review | Interval |
|-------|--------|------------|-------------|-------------|----------|
| [Topic] | [Module] | 2/2 | YYYY-MM-DD | YYYY-MM-DD | 7d |

## Session History

### YYYY-MM-DD — [Module(s)]
- Score: X/Y (Z%)
- Topics: [topic1] (2/2), [topic2] (1/2), [topic3] (0/2)
- Misconceptions: [brief note of any wrong answers]
```

**Review interval calculation:**
- Score 0 → review in 1 day
- Score 1 → review in 3 days
- Score 2 → current interval × 2 (minimum 7 days, maximum 30 days)
- First time drilled → Score 0: 1 day, Score 1: 3 days, Score 2: 7 days

**Update `.study/progress.md`:**
- Add session log entry: "YYYY-MM-DD: Drill session — [module(s)], score X/Y"

**Update `.study/qna-log.md`:**
- If any score-0 answers revealed misconceptions, append them as new entries with `priority: high`

### Important

- **Be strict.** This is active recall — the point is to expose gaps. Don't give away answers in the question, and don't be lenient in grading.
- **Use real content.** Every question must be traceable to specific lecture material. Generic textbook questions don't test whether the student learned THEIR material.
- **One question at a time.** Don't dump all questions at once. The interactive loop is essential for the learning effect.
- **Cite sources in feedback.** When correcting, reference "From [Module] week-NN, slide/page X..."
- **Track misconceptions.** Wrong answers are valuable data — record them for future diagnosis.
- **Terminal only.** 10-15 lines for the summary. No auto-render.
