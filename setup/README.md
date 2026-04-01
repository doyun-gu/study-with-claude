# Setup Guide

Everything you need to connect study-with-claude to both **Claude Code** and **Claude Desktop**.

---

## 1. Claude Code Setup (required)

```bash
# Clone the repo
git clone https://github.com/doyun-gu/study-with-claude.git
cd study-with-claude

# Run the installer
bash install.sh
```

This installs:
- All slash commands to your study directory
- `CLAUDE.md` instructions
- `.study/` state directory
- Background daemon scripts (macOS)
- `/where-is-god` and `/update-thunder` global commands

Then open your study directory in Claude Code:
```bash
cd ~/study    # or wherever STUDY_DIR points
claude
/init-session
```

---

## 2. Claude Desktop Setup

### Step 1: Configure MCP (filesystem read/write access)

Claude Desktop needs MCP to read your study materials and write to `.study/` state files. Copy the example config:

```bash
# macOS
cp setup/claude-desktop-config.example.json \
   "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# Windows
# Copy to %APPDATA%\Claude\claude_desktop_config.json

# Or merge into your existing config if you already have one
```

**Edit the config** — replace `YOUR_STUDY_DIR` with the absolute path to your study directory (e.g., `/Users/alice/study` or `/home/bob/study`).

This gives Claude Desktop read/write access to:
- Your study materials (PDFs, notes, slides)
- `.study/` state files (qna-log, progress, drill scores)
- Task queue files (for delegating work to Claude Code)

See [`claude-desktop-config.example.json`](./claude-desktop-config.example.json) for the full template.

> **Broader access:** If you want Claude Desktop to also read files outside your study directory (e.g., course folders elsewhere on disk), change `YOUR_STUDY_DIR` to your home directory path instead. This is less restrictive but more convenient if your materials are spread across multiple locations.

### Step 2: Add project instructions

1. Open **Claude Desktop**
2. Create a new **Project** (or open an existing one)
3. Open [`desktop-instructions-template.md`](../desktop-instructions-template.md)
4. **Find and replace** `$STUDY_DIR` with your actual study directory path (e.g., `/Users/alice/study`)
5. Paste the contents into the Project's **custom instructions**

### Step 3: Restart Claude Desktop

Restart the app so MCP picks up the new config. You should now be able to ask Claude Desktop about your study materials.

---

## 3. Feynman Research Agent (optional)

[Feynman](https://github.com/getcompanion-ai/feynman) is a multi-agent research tool that does deep, cited research. study-with-claude integrates it via the `/deepresearch` command.

### Install Feynman

```bash
curl -fsSL https://feynman.is/install | bash
feynman setup    # interactive — sets API keys
feynman doctor   # verify installation
```

### Configure API keys

Set in `~/.feynman/.env`:

```bash
FEYNMAN_MODEL=anthropic/claude-sonnet-4    # or openai/gpt-4o
FEYNMAN_THINKING=medium                     # low | medium | high
ANTHROPIC_API_KEY=sk-...                    # your Anthropic key
# OR
OPENAI_API_KEY=sk-...                       # your OpenAI key
```

### How it works with study-with-claude

| Command | What it does |
|---------|-------------|
| `/deepresearch [topic]` | Multi-agent investigation with cited sources |
| `feynman lit "[topic]"` | Literature review with consensus/gap analysis |
| `feynman compare "[A] vs [B]"` | Source comparison matrix |
| `feynman review [file]` | Simulated peer review |

Research outputs land in `./outputs/` with `.provenance.md` sidecars tracking every source.

### Study-specific examples

```bash
# Deep dive into a concept before an exam
/deepresearch "Nyquist stability criterion — derivation, intuition, and common exam pitfalls"

# Compare methods you're studying
feynman compare "Jacobi vs Gauss-Seidel vs SOR iterative methods for linear systems"

# Literature review for a dissertation or project
feynman lit "dynamic phasor simulation methods for power systems"

# Verify your understanding against papers
feynman review subjects/numerical-analysis/big-picture.md
```

See [`feynman.md`](./feynman.md) for the full reference.

---

## 4. Config File Reference

### Claude Code config (`.claude/settings.local.json`)

This is auto-installed by `install.sh`. It grants Claude Code permission to:
- Read/write `.study/` state files
- Read all PDFs, markdown, and text files
- Run the render script and study tools

### Claude Desktop config (`claude_desktop_config.json`)

Location:
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

The config sets up:
- **`filesystem` MCP server** — gives Claude Desktop read/write access to your study directory so it can read materials and write to `.study/` state files (qna-log, drill-log, task queue)
- **`preferences`** — enables scheduled tasks and web search for research

See [`claude-desktop-config.example.json`](./claude-desktop-config.example.json) for the template. Replace `YOUR_STUDY_DIR` with your actual study directory path.

### Feynman config (`~/.feynman/.env`)

Created by `feynman setup`. Contains your API keys and model preferences.

---

## Directory Layout After Setup

```
~/study/                          # Your study directory (STUDY_DIR)
├── CLAUDE.md                     # Instructions for Claude Code
├── .claude/
│   ├── commands/                 # 18 slash commands
│   └── settings.local.json       # Permissions
├── .study/                       # State files (gitignored)
│   ├── modules.md                # Module registry
│   ├── progress.md               # Coverage + exam dates
│   ├── qna-log.md                # All Q&A history
│   ├── content-index.md          # Topic → file:pages
│   ├── tasks/                    # Task queue for daemon
│   └── ...
├── .study-tools/                 # Render scripts
├── .study-daemon/                # Background automation
├── subjects/                     # Your study materials
│   ├── linear-algebra/
│   │   ├── materials/            # ← Drop PDFs here
│   │   ├── big-picture.md
│   │   └── ...
│   └── ...
└── outputs/                      # Feynman research outputs
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Claude Desktop can't read files | Check MCP config path, restart Claude Desktop |
| `/init-session` doesn't find modules | Make sure materials are in `subjects/*/materials/` |
| Feynman not found | Run `feynman doctor`, check `~/.feynman/.env` |
| Daemon not running | `bash ~/.study-daemon/ctl.sh status` |
| Commands missing | Re-run `bash install.sh` |
