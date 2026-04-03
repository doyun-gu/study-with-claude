Daily review dashboard — shows what needs reviewing today, then runs through the queue.

Arguments: $ARGUMENTS
(Optional: "status" for dashboard only, or a module name to filter)

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **"status":** Show dashboard only, don't start reviewing
- **Module filter:** If a module name is given, filter the queue to that module only
- **No arguments:** Show dashboard + start reviewing

Examples:
- `/review` → dashboard + start review session
- `/review status` → dashboard only
- `/review EE301` → dashboard + review EE301 items only

### Step 2: Merge Daily Q&A, Then Load All Review Data

**Before reading `qna-log.md`, merge any unmerged daily files:**
1. List all `.md` files in `.study/qna-daily/`
2. If any exist: read each one, append entries to `qna-log.md` (dedup by concept — increment `asked_count` on matches), update `total_questions` and `last_updated` in the YAML header, then delete the daily files.

Read:
- `.study/drill-log.md` — drill review schedule (if exists)
- `.study/flash-log.md` — flashcard intervals and due dates (if exists)
- `.study/qna-log.md` — repeated questions, misconceptions (now includes merged Desktop entries)
- `.study/progress.md` — session history, exam dates
- `.study/diagnosis.md` — weak areas (if exists)
- `.study/past-paper-analysis.md` — exam frequencies (if exists)

If neither `drill-log.md` nor `flash-log.md` exists:
> "No review data yet. Run `/drill` or `/flash` first to build your review queue."

Stop here.

### Step 3: Build Today's Queue

Gather all reviewable items and sort by priority:

1. **Overdue flashcards:** Cards in `flash-log.md` with `next_review` < today. Oldest overdue first.
2. **Overdue drill topics:** Topics in `drill-log.md` with `next_review` < today. Lowest last score first.
3. **Due today (flashcards):** Cards with `next_review` = today
4. **Due today (drill topics):** Topics with `next_review` = today
5. **Stale topics:** Topics not reviewed in >14 days AND high exam frequency (from `past-paper-analysis.md`)
6. **Repeatedly confused:** Topics from `qna-log.md` with `asked_count ≥ 3` that haven't been drilled recently

Apply module filter if specified.

### Step 4: Display Dashboard

Print the review dashboard:

```
╔═══════════════════════════════════════════════╗
║              DAILY REVIEW                     ║
║              YYYY-MM-DD                       ║
╠═══════════════════════════════════════════════╣
║                                               ║
║  OVERDUE                                      ║
║  🔴 N flashcards overdue (oldest: N days)    ║
║  🔴 N drill topics overdue                   ║
║                                               ║
║  DUE TODAY                                    ║
║  📋 N flashcards to review                   ║
║  📋 N drill topics to review                 ║
║                                               ║
║  STALE (>14 days untouched)                   ║
║  ⚠  N high-frequency topics need refresh     ║
║                                               ║
║  UPCOMING THIS WEEK                           ║
║  📅 N flashcards | N drill topics             ║
║                                               ║
╠═══════════════════════════════════════════════╣
║  Review streak: N days                        ║
║  Total queue: N items (~N min estimated)      ║
╚═══════════════════════════════════════════════╝
```

**Time estimates:**
- Flashcard: ~30 seconds per card
- Drill topic: ~3 minutes per topic
- Stale topic refresher: ~2 minutes per topic

If `$ARGUMENTS` is "status", stop here after showing the dashboard.

### Step 5: Run Review Session

Work through the queue in priority order. For each item, dispatch to the appropriate interaction type:

**Flashcard items** (from `flash-log.md`):
- Show the card front
- Wait for answer
- Reveal correct answer
- Ask for self-rating (1/2/3)
- Update interval using the same algorithm as `/flash`

**Drill items** (from `drill-log.md`):
- Ask one question on the topic (same question style as `/drill`)
- Wait for answer
- Grade (0/1/2) with feedback
- Update interval using the same algorithm as `/drill`

**Stale topic refreshers:**
- Give a brief 2-3 sentence summary of the topic
- Ask one quick question to test recall
- Grade and add to `drill-log.md` with appropriate interval

**Repeatedly confused topics:**
- Point out that this topic has been asked about N times
- Ask a targeted question focusing on the common confusion
- Grade and update

Between items, show progress: `[3/12 completed]`

### Step 6: Session Summary

After completing the queue (or if the student says "stop"/"done"/"quit"):

```
╔═══════════════════════════════════════════════╗
║           REVIEW COMPLETE                     ║
╠═══════════════════════════════════════════════╣
║  Items reviewed: N/N                          ║
║  Flashcards: N (retention: N%)               ║
║  Drill topics: N (avg score: N/2)            ║
║  Refreshers: N                                ║
║                                               ║
║  Review streak: N days                        ║
║  Next review: tomorrow (N items due)          ║
╚═══════════════════════════════════════════════╝
```

### Step 7: Update State Files

**Update `.study/flash-log.md`:**
- Update intervals and next review dates for all reviewed flashcards
- Update session history

**Update `.study/drill-log.md`:**
- Update scores and next review dates for all reviewed drill topics
- Add new entries for stale topics that were tested
- Update session history

**Update `.study/progress.md`:**
- Add session log entry: "YYYY-MM-DD: Review session — N items reviewed, streak: N days"
- Update or add review streak counter

**Review streak tracking:**
- A "review day" counts if the student completed at least one review item
- Streak = consecutive days with at least one review
- Store `last_review_date` and `review_streak` in `progress.md` metadata
- If `last_review_date` is yesterday → streak + 1
- If `last_review_date` is today → streak unchanged
- If `last_review_date` is >1 day ago → streak resets to 1

### Important

- **Start with the dashboard.** Always show the full queue before starting. Let the student see what's ahead.
- **Respect "stop."** If the student wants to end early, save progress on what was completed and show partial summary.
- **Mix item types.** Don't do all flashcards then all drills — interleave for variety when possible.
- **Keep it moving.** Review sessions should feel brisk. Don't over-explain unless the student got something wrong.
- **Track the streak.** The streak is a motivational tool — display it prominently.
- **Estimate time.** The student should know upfront how long the review will take so they can plan.
- **Terminal only.** 15-20 lines for dashboard, 5-10 lines for summary. No auto-render.
