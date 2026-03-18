Answer a study question directly with full sourcing and equations.

Student's question: $ARGUMENTS

## Instructions

You are answering a student's question in **direct answer mode**. This is the ONE command where you skip the Socratic method and give a complete, sourced answer.

### Step 1: Load Context

- Read `.study/context.md` to understand available materials and modules.
- Read `.study/qna-log.md` if it exists, to check for similar past questions.

### Step 2: Check for Duplicate Questions

Perform **concept-level deduplication** (not string matching). For example:
- "What is Thevenin's theorem?" and "How does Thevenin's theorem work?" are the SAME concept.
- "What is impedance?" and "What is resistance?" are DIFFERENT concepts.

If a similar question was asked before:
- Reference the previous answer: "You asked about this on [date]. Here's an updated/expanded answer..."
- Increment `asked_count` in the log entry
- If `asked_count >= 3`, set priority to `critical` — this is a concept the student keeps returning to

### Step 3: Answer the Question

Provide a thorough, direct answer:

1. **Identify the module, week, and topic.** e.g., "This is from EE301, week-04: AC Circuit Analysis."
2. **Cite the source material.** Reference specific files and pages: "From week-04/slides.pdf, page 12..."
3. **Include equations** in LaTeX. Use `$inline$` and `$$block$$` formatting.
4. **Explain the exam relevance.** If this topic appears in past papers (check `.study/past-paper-analysis.md` if it exists), mention the frequency and typical question format.
5. **Connect to related concepts.** If this links to other modules or topics, mention it.
6. **Include a worked example** if the concept involves calculation.

### Step 4: Update Q&A Log

Append to `.study/qna-log.md` (create if it doesn't exist). Use this schema:

```markdown
## [Date] — [Short Question Title]

- **Module:** [module name]
- **Topic:** [specific topic]
- **Week:** [week-NN if identifiable]
- **Asked count:** [N — increment if similar question exists]
- **Priority:** [normal / high / critical]

### Question
[Student's original question]

### Answer
[Your complete answer with equations and sources]

### Why It Matters
[1-2 sentences on exam relevance and connections to other topics]

### Related Concepts
- [Concept 1] (Module, Week)
- [Concept 2] (Module, Week)

---
```

### Step 5: Update Progress

Update `.study/progress.md`:
- Mark the relevant topic as covered (check the checkbox if using todo format)
- Increment `total_questions`
- Update `last_session` date

### Step 6: Terminal Output

Print a concise answer to the terminal (5-15 lines):

1. **Use ASCII-safe math** in the terminal: `V = IR` not `$V = IR$`. Write `omega` not `$\omega$`, `sqrt(2)` not `$\sqrt{2}$`.
2. **Complex equations** (integrals, matrices, summations): describe in words + reference file: `[see .study/qna-log.md for full derivation]`
3. End with: `Logged to .study/qna-log.md`
4. Every 5th `/why` question in a session, append: `Tip: bash .study-tools/render.sh .study/qna-log.md to view all Q&A with rendered equations.`
5. Do NOT auto-open the browser — `/why` is conversational and browser popups would be disruptive.

### Important

- Always read the actual source material when answering — don't rely on summaries alone
- If the question is about something not in the student's materials, say so clearly
- If the question spans multiple modules, address each module's perspective
- Use precise, technical language. No hand-waving.
