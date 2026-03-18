Analyze past exam papers and build a frequency matrix of tested topics.

## Instructions

### Step 1: Locate Past Papers

Scan for past papers in these locations:
1. `past-papers/` directory at repository root
2. `[module]/past-papers/` directories within each module
3. Any file with "exam", "test", "assessment", "midterm", "final", or "quiz" in the filename (case-insensitive)

### Step 2: Read Each Paper

For each past paper found:
- Read the full content (for PDFs, paginate at 20 pages per read)
- For image-based papers (scanned PDFs, `.png`, `.jpg`), describe the visual content
- Extract:
  - **Year/semester** (from filename or content)
  - **Module** (from directory or content)
  - **Question structure** (number of questions, sections, parts)
  - **Topics per question** (what concept each question tests)
  - **Question types:** calculation, derivation, proof, explain/discuss, design/application, compare/contrast, short answer
  - **Marks allocation** per question/part

### Step 3: Build Frequency Matrix

Create a matrix of Topic vs. Year showing which topics appear in which exams.

Categorize each topic by exam frequency:
- **Always tested (>80%):** Appears in >80% of available papers
- **Frequently tested (50-80%):** Appears in 50-80% of papers
- **Sometimes tested (20-50%):** Appears in 20-50% of papers
- **Rarely tested (<20%):** Appears in <20% of papers
- **Never tested but in syllabus:** Covered in lectures but never examined (check against `.study/context.md`)

### Step 4: Detect Patterns

Look for:
- **Repeated questions:** Nearly identical questions across years (flag as "banker questions")
- **Mark allocation trends:** Are certain topics always high-mark questions?
- **Question format patterns:** Does Topic X always appear as a calculation? Always in Section A?
- **Rotating topics:** Topics that appear every other year
- **Increasing/decreasing trends:** Topics becoming more or less frequent over time

### Step 5: Generate Analysis File

Write `.study/past-paper-analysis.md`:

```markdown
---
last_analysis: YYYY-MM-DD
papers_analyzed: N
modules_covered: [list]
---

# Past Paper Analysis

## Papers Analyzed

| Paper | Module | Year | Questions | Total Marks |
|-------|--------|------|-----------|-------------|
| [filename] | [module] | [year] | [N] | [N] |

## Frequency Matrix

### [Module Name]

| Topic | 2020 | 2021 | 2022 | 2023 | 2024 | Frequency |
|-------|------|------|------|------|------|-----------|
| [Topic] | ✓ (Q1, 20mk) | ✓ (Q3, 15mk) | — | ✓ (Q2, 25mk) | ✓ (Q1, 20mk) | 80% |

## Topic Categories

### Always Tested (>80%)
- [Topic]: [avg marks], typically as [question type]

### Frequently Tested (50-80%)
- [Topic]: [avg marks], typically as [question type]

### Sometimes Tested (20-50%)
- [Topic]: ...

### Rarely Tested (<20%)
- [Topic]: ...

### Never Tested But In Syllabus
- [Topic]: Covered in [week], never examined. **Risk:** Could appear this year.

## Banker Questions (Repeated Patterns)
- [Description of repeated question pattern, which years it appeared]

## Exam Strategy Recommendations
1. [Prioritized recommendation based on frequency data]
2. [...]
```

### Step 6: Terminal Summary + Browser Render

**Terminal (5-10 lines only):**
- Number of papers analyzed
- Top 5 most frequently tested topics (with frequency %)
- Banker questions detected (if any)

**Then render in browser:**
```bash
bash .study-tools/render.sh .study/past-paper-analysis.md
```

End with:
```
Full analysis opened in browser
```

### Important

- If no past papers are found, inform the student and suggest where to add them
- Cross-reference with `.study/context.md` to identify syllabus topics never tested
- If past papers are image-based (scanned), do your best to extract content from the images
