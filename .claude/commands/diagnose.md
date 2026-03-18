Diagnose weak areas, knowledge gaps, and study priorities based on all available data.

## Instructions

### Step 1: Read All State Files

Load every available `.study/` file:
- `context.md` — module inventory and topics
- `qna-log.md` — question history and priorities
- `progress.md` — coverage metrics and exam dates
- `past-paper-analysis.md` — exam topic frequencies
- `big-picture.md` — concept inventory
- `drill-log.md` — drill scores, review schedule
- `flash-log.md` — flashcard performance, ease factors

If some files don't exist, work with what's available. Note what's missing and recommend the student run the relevant commands.

### Step 2: Identify Weakness Signals

Look for these indicators:

**From Q&A Log:**
- **Repeated questions** (`asked_count >= 2`): Student keeps returning to this concept → not fully understood
- **High/critical priority topics**: Previously flagged as problematic
- **Corrected misconceptions**: Topics where the student was wrong

**From Progress:**
- **Uncovered topics**: Topics in the syllabus with zero questions asked
- **Stale topics**: Studied more than 2 weeks ago with no review since
- **Low coverage modules**: Modules with <30% topic coverage

**From Past Paper Analysis (if available):**
- **High-frequency exam topics not yet studied**: Critical gap
- **Banker questions the student hasn't practiced**: Missed easy marks

**From Drill Log (if available):**
- **Low drill scores**: Topics scored 0 or 1 in recent drills → not understood
- **Frequently drilled but still failing**: Topics drilled multiple times with no score improvement
- **Overdue drill reviews**: Topics past their next review date

**From Flash Log (if available):**
- **Low ease cards**: Cards with ease factor < 1.8 → repeatedly forgotten
- **High wrong-rating frequency**: Cards rated 1 (wrong) more than twice
- **Overdue flashcards**: Cards past their next review date, especially if also low ease

**From Context:**
- **Unread materials**: Files that exist but topics haven't been asked about
- **Missing weeks**: Gaps in the material sequence

### Step 3: Cross-Reference with Exam Risk

For each weakness, calculate an **exam risk score**:
- High exam frequency + weakness signal = **CRITICAL**
- High exam frequency + no coverage = **HIGH**
- Medium exam frequency + weakness signal = **MODERATE**
- Low exam frequency + weakness signal = **LOW**
- Not in exam + weakness signal = **INFORMATIONAL**

### Step 4: Generate Diagnosis Report

Write `.study/diagnosis.md`:

```markdown
---
diagnosis_date: YYYY-MM-DD
overall_readiness: [percentage estimate]
critical_gaps: N
moderate_gaps: N
---

# Study Diagnosis

## Exam Countdown
| Module | Exam Date | Days Left | Readiness |
|--------|-----------|-----------|-----------|
| [Module] | YYYY-MM-DD | N | [Low/Medium/High] |

## Critical Gaps (Act Now)
These are high exam-risk topics where you have weakness signals.

### [Topic Name] — [Module]
- **Exam frequency:** [N%]
- **Signal:** [repeated questions / zero coverage / stale / misconception]
- **Action:** [specific recommendation: re-read week-X, practice Y type problems, review Z]
- **Source material:** [file path]

## Moderate Gaps (This Week)
...

## Blind Spots (Never Touched)
Topics in your syllabus you haven't studied at all:
- [Topic] — [Module], [Week] — Exam frequency: [N%]

## Strong Areas
Topics you've demonstrated understanding of:
- [Topic] — [Module] — [evidence: correct answers, multiple reviews]

## Recommended Study Plan

### Today
1. [Most critical action with specific file/topic reference]
2. [Second priority]

### This Week
1. [...]
2. [...]
3. [...]

### Before Exam
1. [...]
```

### Step 5: Print Terminal Summary

**Terminal (10-15 lines max):**
- Exam countdowns (one line per module)
- Critical gap count + moderate gap count
- Top 3 most urgent actions (specific and actionable)
- Overall readiness estimate per module

Do NOT auto-render in browser (diagnosis is mostly text, not equation-heavy).

End with:
```
Full diagnosis: .study/diagnosis.md | Render: bash .study-tools/render.sh .study/diagnosis.md
```

### Important

- Be brutally honest about gaps. The student needs truth, not comfort.
- Every recommendation must be actionable: specific topic, specific material, specific action.
- If the student has no Q&A history, the diagnosis is limited — say so and recommend they start with `/why` questions.
- If no past paper analysis exists, recommend running `/past-papers` first for a more complete diagnosis.
