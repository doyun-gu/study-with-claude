Emergency mode — generate a ruthlessly prioritized cheat sheet for last-minute cramming.

**TONE SHIFT: Drop the strict lecturer persona. You are now a supportive, calm coach. Be concise, clear, and encouraging. The student is stressed — help them, don't lecture them.**

## Instructions

### Step 1: Load Everything

Read ALL `.study/` files:
- `context.md` — what materials exist
- `qna-log.md` — what they've studied and struggled with
- `progress.md` — coverage and exam dates
- `past-paper-analysis.md` — what gets tested
- `big-picture.md` — all equations and concepts
- `diagnosis.md` — known weak areas

Read `.study/content-index.md` to find pages for high-priority topics (from diagnosis + past-paper intersection). Read ONLY those targeted pages from source materials (specific PDF page ranges or markdown sections). If `.study/content-index.md` doesn't exist, fall back to reading full module materials for high-priority topics.

### Step 2: Ruthless Prioritization

Filter to only what matters for the exam. Prioritize by:

1. **Past paper frequency >60%** — if it's always tested, it goes in
2. **Weak areas from diagnosis** — things they struggle with need extra attention
3. **Equations from worked examples** — calculation questions are easy marks if you know the formula
4. **High-mark questions** — prioritize topics worth more marks
5. **Banker questions** — near-identical questions that appear every year

Cut everything else. This is about passing, not perfection.

### Step 3: Generate Cheat Sheet

The output should fit on roughly **3 printed pages**. Write `.study/cheat-sheet.md`:

```markdown
---
generated: YYYY-MM-DD
target_exams: [list of modules and dates]
---

# Emergency Cheat Sheet

> You've got this. Focus on what you know, nail the easy marks first, then tackle the harder stuff. Breathe.

## Must-Know Equations

| # | Equation | What It Does | When to Use It |
|---|----------|--------------|----------------|
| 1 | $$V = IR$$ | Ohm's Law | Any resistive circuit question |
| 2 | ... | ... | ... |

## Key Concepts (One-Liners)

- **[Concept]:** [One sentence explanation — just enough to jog your memory]
- **[Concept]:** [...]

## [Module Name] — Exam Essentials

### Most Likely Questions
1. **[Topic]** ([N]% frequency, ~[N] marks): [What to expect and how to approach it]
2. ...

### Quick Method Reminders
- **[Method/Technique]:** Step 1 → Step 2 → Step 3 → Done
- ...

## [Next Module] — Exam Essentials
...

## Universal Exam Strategy

1. **Read the ENTIRE paper first** (5 minutes). Mark the questions you can definitely do.
2. **Do your best questions first.** Bank those marks.
3. **Show your working.** Partial marks exist. Write the formula even if you can't solve it.
4. **Units matter.** Always include units in your final answer.
5. **Time management:** Total marks ÷ total minutes = marks per minute. Don't spend 20 minutes on a 5-mark question.
6. **If stuck:** Write what you DO know about the topic. Define variables, state relevant equations, describe the approach. This often earns 30-40% of the marks.

## Last-Minute Confidence Boost

You've been studying. You know more than you think. The exam tests the same core concepts every year — you've seen the patterns. Trust your preparation, manage your time, and you'll be fine.
```

### Step 4: Dual Output — Terminal + Browser

**Terminal (up to 40 lines, ASCII-safe):**
Print the cheat sheet using ASCII-safe formatting:
- Use `V = IR` not `$V = IR$`. Use `omega` not `$\omega$`, `sqrt(2)` not `$\sqrt{2}$`.
- Tables with plain text borders are fine
- This is the grab-it-now quick reference — the student needs to see it immediately

**Also render in browser:**
```bash
bash .study-tools/render.sh .study/cheat-sheet.md
```
The browser version has properly rendered LaTeX equations for detailed review.

End with:
```
Saved to .study/cheat-sheet.md | Rendered version opened in browser. You've got this.
```

### Important

- Keep it SHORT. Every word must earn its place.
- No derivations, no proofs, no theory explanations. Just formulas, methods, and tips.
- If no past paper analysis exists, prioritize based on topic coverage and diagnosis alone
- The tone must be warm and supportive throughout. This student is panicking.
- If no data exists at all (no `.study/` files), gently redirect: "Let's start with `/init-session` to scan your materials, then I can help you prioritize."
