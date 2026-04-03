Show a progress dashboard with coverage metrics, exam countdown, and recommended focus.

Arguments: $ARGUMENTS
(Optional: manual progress update, e.g., "studied EE301 week-05")

## Instructions

### Step 1: Check for Manual Update

If `$ARGUMENTS` contains a manual update (e.g., "studied EE301 week-05"):
- Parse the module and topic/week
- Update `.study/progress.md` to mark that topic as covered
- Confirm: "Marked [topic] in [module] as studied."

### Step 2: Merge Daily Q&A, Then Load State

**Before reading `qna-log.md`, merge any unmerged daily files:**
1. List all `.md` files in `.study/qna-daily/`
2. If any exist: read each one, append entries to `qna-log.md` (dedup by concept — increment `asked_count` on matches), update `total_questions` and `last_updated` in the YAML header, then delete the daily files.

Read:
- `.study/progress.md` — coverage data, exam dates, session history
- `.study/context.md` — total topics per module
- `.study/qna-log.md` — question count and topics asked about (now includes merged Desktop entries)
- `.study/diagnosis.md` — weak areas (if exists)
- `.study/drill-log.md` — drill scores and review schedule (if exists)
- `.study/flash-log.md` — flashcard intervals and due dates (if exists)

If `.study/progress.md` doesn't exist, create it with defaults and note that `/init-session` should be run.

### Step 3: Calculate Metrics

**Per-module metrics:**
- Topics covered / total topics (from context.md)
- Questions asked (from qna-log.md)
- Weak areas count (from diagnosis.md)
- Days until exam
- Topics per day needed to finish (remaining topics ÷ days left)

**Review metrics (from drill-log.md and flash-log.md):**
- Review streak: consecutive days with completed reviews (from progress.md)
- Cards due today: flashcards with `next_review` ≤ today (from flash-log.md)
- Drill score trend: average score of last 3 drill sessions (from drill-log.md)
- Overdue items: total overdue flashcards + drill topics

**Overall metrics:**
- Total sessions (from progress.md session log)
- Total questions asked
- Days since first session
- Average questions per session

### Step 4: Generate Dashboard

Print an ASCII dashboard to the terminal:

```
╔══════════════════════════════════════════════════════╗
║                 STUDY PROGRESS                       ║
╠══════════════════════════════════════════════════════╣
║                                                      ║
║  EE301-Circuits          Exam: 2024-06-15 (23 days) ║
║  ████████░░░░░░░░░░░░  38%  (8/21 topics)          ║
║  Questions: 15 | Weak areas: 3                       ║
║  Pace needed: 0.6 topics/day                         ║
║                                                      ║
║  MATH201-Linear-Algebra  Exam: 2024-06-20 (28 days) ║
║  ████████████░░░░░░░░  55%  (11/20 topics)          ║
║  Questions: 22 | Weak areas: 1                       ║
║  Pace needed: 0.3 topics/day                         ║
║                                                      ║
╠══════════════════════════════════════════════════════╣
║  Sessions: 12 | Total questions: 37                  ║
║  Since: 2024-05-01 (45 days)                         ║
║  Avg: 3.1 questions/session                          ║
╠══════════════════════════════════════════════════════╣
║  REVIEW STATUS                                       ║
║  Streak: N days | Cards due: N | Drills due: N      ║
║  Drill trend (last 3): N% avg                        ║
║  Overdue: N items                                     ║
╠══════════════════════════════════════════════════════╣
║  TODAY'S RECOMMENDED FOCUS                           ║
║  1. EE301: Review Thevenin's theorem (weak area)    ║
║  2. EE301: Practice AC analysis problems             ║
║  3. MATH201: Read week-12 eigenvalues               ║
╚══════════════════════════════════════════════════════╝
```

The progress bar should be proportional: each `█` represents ~5% coverage.

### Step 5: Update Progress File

Update `.study/progress.md` with:
- Current date as `last_session`
- Any manual updates from arguments
- Recalculated metrics

### Step 6: Recommendations

Based on the data, recommend today's focus:
1. Highest priority from diagnosis (if available)
2. Closest exam with lowest coverage
3. Stale topics that need review

### Important

- If exam dates aren't set, prominently note: "No exam dates set. Run `/init-session` to add them — this enables countdown and pace tracking."
- If coverage is very low and exam is close, add an urgency note and suggest `/i-am-fucked`
- Progress bars should work even with 0% or 100% coverage (edge cases)
- The dashboard should be readable in a standard terminal width (~80 chars)
