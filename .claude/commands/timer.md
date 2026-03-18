Set a study timer with an audio alert when time is up.

Arguments: $ARGUMENTS
(Required: duration in hours, e.g., 2, 1.5, 0.5)

## Instructions

### Step 1: Parse Duration

Parse `$ARGUMENTS` as a duration in hours:
- `2` → 2 hours (7200 seconds)
- `1.5` → 1 hour 30 minutes (5400 seconds)
- `0.5` → 30 minutes (1800 seconds)
- `0.25` → 15 minutes (900 seconds)

If no argument is provided, default to **1 hour**.

If the argument is not a valid number, tell the student: "Usage: `/timer [hours]` — e.g., `/timer 2` for a 2-hour session, `/timer 0.5` for 30 minutes."

### Step 2: Calculate Times

- Calculate the total seconds
- Determine the end time (current time + duration)
- Format both start and end times in HH:MM format

### Step 3: Start the Timer

Run a background bash command:

```bash
(sleep [total_seconds] && printf '\a' && echo "" && echo "════════════════════════════════" && echo "  ⏰ TIME IS UP — [duration] elapsed" && echo "════════════════════════════════" && echo "" && say "Time is up. Take a break.") &
```

The `say` command provides audio feedback on macOS. The `\a` triggers a terminal bell.

### Step 4: Print Confirmation

Display:

```
⏱ Timer started
  Duration: [X] hour(s) [Y] minutes
  Started:  HH:MM
  Ends at:  HH:MM

Focus time. I'll alert you when it's up.
Tip: Use this time for focused study — try /why or work through problems.
```

### Important

- The timer runs as a background process — it won't block the terminal
- If the student starts a new timer, the old one still runs (they stack)
- The `say` command is macOS-specific. On Linux, the terminal bell (`\a`) will be the only alert. Note this if relevant.
- For very short timers (< 1 minute), warn that this might be too short for focused study
