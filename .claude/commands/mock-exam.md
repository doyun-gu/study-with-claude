Generate a practice exam that matches past paper style and targets weak areas.

Arguments: $ARGUMENTS
(Optional: module name, difficulty level [easy/medium/hard], topic filter)

## Instructions

### Step 1: Parse Arguments

Parse `$ARGUMENTS` for:
- **Module name:** If specified, generate exam for that module only. If blank, generate for the module with the nearest exam date.
- **Difficulty:** `easy`, `medium` (default), or `hard`
- **Topic filter:** If specified, focus on that topic area

Examples:
- `/mock-exam` → default module, medium difficulty
- `/mock-exam EE301` → EE301, medium difficulty
- `/mock-exam EE301 hard` → EE301, hard difficulty
- `/mock-exam EE301 hard circuit-analysis` → EE301, hard, focused on circuit analysis

### Step 2: Load Sources

Read:
- `.study/past-paper-analysis.md` — for question patterns, mark allocation, and format
- `.study/diagnosis.md` — for weak areas to target
- `.study/context.md` — for available material
- `.study/big-picture.md` — for equations and concepts to test
- Module lecture materials — for worked examples to vary

### Step 3: Design the Exam

Generate questions matching past paper conventions:

1. **Structure:** Match the typical past paper format (number of sections, questions per section, total marks)
2. **Question types:** Mix according to past paper patterns (calculation, derivation, explanation, design)
3. **Mark allocation:** Match typical mark distributions
4. **Difficulty calibration:**
   - Easy: straightforward application of formulas, similar to lecture examples
   - Medium: requires combining 2-3 concepts, numbers varied from worked examples
   - Hard: multi-step problems requiring deep understanding, edge cases, or novel applications
5. **Weak area targeting:** At least 30% of marks should come from topics flagged in diagnosis
6. **Wild card:** Include at least one question on a "never tested" topic (from past paper analysis) — these are the surprises students don't prepare for

### Step 4: Generate Numbers

- Vary numbers from worked examples — don't use identical values
- Ensure numbers produce clean intermediate results where possible
- For calculation questions, verify the arithmetic yourself

### Step 5: Write the Exam

Save to `.study/mock-exams/YYYY-MM-DD-[module].md`:

```markdown
---
date: YYYY-MM-DD
module: [module name]
difficulty: [easy/medium/hard]
total_marks: N
duration: [estimated time based on past papers]
---

# Mock Exam — [Module Name]
**Date:** YYYY-MM-DD | **Difficulty:** [level] | **Total Marks:** N | **Duration:** [time]

---

## Section A: [Section Title] (N marks)

### Question 1 (N marks)
[Question text with any diagrams described]

**(a)** [Part a] (N marks)

**(b)** [Part b] (N marks)

### Question 2 (N marks)
...

---

## Section B: [Section Title] (N marks)
...

---
---

# Solutions

## Question 1

### Part (a)
**[Step-by-step solution with equations]**

$$[equation]$$

[Explanation of each step]

**Common mistake:** [What students typically get wrong here and why]

**Answer:** [final answer with units]

### Part (b)
...
```

### Step 6: Render + Terminal Summary

**Render in browser:**
```bash
bash .study-tools/render.sh .study/mock-exams/YYYY-MM-DD-[module].md
```

**Terminal output (5-10 lines):**
- Module, difficulty, total marks, estimated duration
- Number of questions, sections
- Topics targeted (especially weak areas)
- End with: `Mock exam opened in browser. Solutions included at the bottom.`

### Step 7: Offer Interactive Mode

After generating and rendering the exam, ask:

> "Want to attempt it now? I'll wait for your answers and grade them — strict lecturer mode. Or review the solutions at your own pace."

If the student wants interactive mode:
- Present one question at a time
- Wait for their answer
- Grade strictly: mark allocation, partial credit for correct method with wrong numbers
- Track results and update `.study/progress.md` with performance

### Important

- If no past paper analysis exists, use a standard exam format and note that running `/past-papers` first would improve exam generation
- Always verify your own solutions are correct before presenting them
- Include units in all numerical answers
- Equations must use LaTeX formatting
