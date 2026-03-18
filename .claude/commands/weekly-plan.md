Generate a structured weekly study plan based on diagnosis, exam dates, and past paper analysis.

## Instructions

### Step 1: Load All State

Read:
- `.study/progress.md` — exam dates, current coverage
- `.study/diagnosis.md` — weak areas, gaps
- `.study/past-paper-analysis.md` — high-frequency topics
- `.study/context.md` — available materials
- `.study/qna-log.md` — what's been studied

If key files are missing, note which commands to run first:
- No `diagnosis.md`? → "Run `/diagnose` first for a more targeted plan."
- No `past-paper-analysis.md`? → "Run `/past-papers` first to prioritize by exam frequency."

### Step 2: Calculate Available Time

From `.study/progress.md`:
- Days until each exam
- Number of uncovered topics per module
- Required pace (topics/day) per module

Assume:
- ~4 hours of effective study per day (adjustable if student specifies)
- ~30-45 minutes per topic for review
- ~1-1.5 hours per topic for new learning
- Past paper practice: ~1 hour per paper

### Step 3: Prioritize Topics

Rank all uncovered/weak topics by priority:
1. **Critical:** High exam frequency + weakness signal + exam within 14 days
2. **High:** High exam frequency + not yet covered
3. **Medium:** Medium exam frequency or needs review
4. **Low:** Low exam frequency, already somewhat familiar

### Step 4: Generate the Plan

Create a 7-day plan with specific daily allocations:

```markdown
---
generated: YYYY-MM-DD
week_of: YYYY-MM-DD to YYYY-MM-DD
modules: [list]
---

# Weekly Study Plan

> Generated based on your current progress, weak areas, and exam schedule.

## Overview
- **Focus modules:** [list in priority order]
- **Key goals this week:** [2-3 bullet points]
- **Exam countdown:** [module] in [N] days, [module] in [N] days

---

## Monday (YYYY-MM-DD)

### Morning Block (2 hours)
**Module:** [Module Name]
- [ ] **[Topic]** — Re-read [week-NN/file.pdf], focus on [specific concept]
- [ ] Practice: Attempt [specific problem type or past paper question reference]

### Afternoon Block (2 hours)
**Module:** [Module Name]
- [ ] **[Topic]** — New material: [week-NN/file.pdf]
- [ ] Summarize key equations (use `/big-picture` to verify)

### Start of Day (10-15 min)
- [ ] Run `/review` to clear your spaced repetition queue

### Evening Review (30 min)
- [ ] Quick review of today's topics — use `/why` for any unclear points

---

## Tuesday (YYYY-MM-DD)
...

## Wednesday (YYYY-MM-DD)
...

## Thursday (YYYY-MM-DD)
...

## Friday (YYYY-MM-DD)
...

## Saturday (YYYY-MM-DD)
### Mock Exam Day
- [ ] Run `/mock-exam [module] medium` and attempt under timed conditions (`/timer 2`)
- [ ] Review solutions, note weak areas
- [ ] Run `/diagnose` to update weak areas

## Sunday (YYYY-MM-DD)
### Light Review + Planning
- [ ] Review week's notes
- [ ] Run `/where-i-am` to check progress
- [ ] Identify topics for next week
- [ ] Rest — burnout kills exam performance

---

## Weekly Targets

| Module | Topics to Cover | Topics to Review | Practice Papers |
|--------|----------------|------------------|-----------------|
| [Module] | [N] new topics | [N] reviews | [N] papers |

## If You're Behind

If you fall behind this schedule:
1. Drop "Low" priority topics first
2. Focus on equations and methods, skip deep theory
3. Run `/i-am-fucked` for emergency prioritization
```

### Step 5: Save and Update

- Write to `.study/weekly-plan.md`
- Update `.study/progress.md` with the planned schedule

### Step 6: Terminal Summary + Browser Render

**Terminal (10 lines):**
- This week's priority modules
- Today's focus: what to work on right now (morning/afternoon blocks)
- Exam countdowns

**Then render in browser:**
```bash
bash .study-tools/render.sh .study/weekly-plan.md
```

End with:
```
Full weekly plan opened in browser
```

### Important

- Balance across modules — don't put all eggs in one basket unless one exam is imminent
- Include rest time. Burnout is real and counterproductive.
- Mix new learning with review/practice — don't front-load all new material
- Include mock exam practice at least once per week
- Be specific: "Re-read week-03 slides, then attempt 2023 Q2" is better than "Study circuit analysis"
- If multiple exams are close together, prioritize the earliest one more heavily
