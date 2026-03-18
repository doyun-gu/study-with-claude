# /where-is-god — Bootstrap study-with-claude

Run the bootstrap script:

```bash
bash "$(dirname "$(readlink "$HOME/.claude/commands/where-is-god.md")")/setup.sh"
```

After the script finishes, check its output for two special cases that need your help:

## Case 1: `__MERGE_SETTINGS__`

If the output contains `__MERGE_SETTINGS__`, the target already has `.claude/settings.local.json`. You need to merge the `permissions.allow` arrays:

1. Read both the SOURCE and TARGET files shown in the output
2. Take the union of both `permissions.allow` arrays (no duplicates)
3. Write the merged result back to `.claude/settings.local.json`, preserving any other keys in the existing file

## Case 2: `__CLAUDEMD_CONFLICT__`

If the output contains `__CLAUDEMD_CONFLICT__`, the target has a CLAUDE.md from another project. Ask the user:

```
CLAUDE.md conflict — your current CLAUDE.md was NOT created by study-with-claude.

Options:
  (a) Backup to CLAUDE.md.backup and replace
  (b) Skip — keep yours (commands still work)
  (c) Abort

What would you like to do? (a/b/c)
```

Then act on their choice:
- **(a)**: `cp CLAUDE.md CLAUDE.md.backup` then copy from the SOURCE path shown
- **(b)**: Do nothing
- **(c)**: Print "Aborted." and stop

## If neither special case appears

Everything was handled by the script. No further action needed — just confirm the summary the script already printed.
