#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
STUDY_DIR="${STUDY_DIR:-$HOME/study}"
DAEMON_CONFIG_DIR="$HOME/.study-daemon"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  study-with-claude v2 installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check Claude Code
if [ ! -d "$CLAUDE_DIR" ]; then
    echo "Error: $CLAUDE_DIR does not exist. Is Claude Code installed?"
    exit 1
fi

# Check Node.js (needed for Claude Desktop MCP)
if ! command -v node &>/dev/null; then
    echo "Warning: Node.js not found. Required for Claude Desktop integration."
    echo "  Install: brew install node"
    echo ""
fi

mkdir -p "$COMMANDS_DIR"

# --- Helper: symlink with backup ---
symlink_file() {
    local SOURCE="$1"
    local TARGET="$2"
    local LABEL="$3"
    if [ -f "$TARGET" ]; then
        if [ -L "$TARGET" ]; then
            LINK_TARGET="$(readlink "$TARGET")"
            if [ "$LINK_TARGET" = "$SOURCE" ]; then
                echo "  [ok] $LABEL already symlinked"
                return
            else
                mv "$TARGET" "$TARGET.backup"
            fi
        else
            mv "$TARGET" "$TARGET.backup"
        fi
    fi
    ln -s "$SOURCE" "$TARGET"
    echo "  [ok] $LABEL"
}

# --- 1. Bootstrap commands (available everywhere) ---
echo "1. Bootstrap commands:"
symlink_file "$SCRIPT_DIR/bootstrap/where-is-god.md" "$COMMANDS_DIR/where-is-god.md" "/where-is-god"
symlink_file "$SCRIPT_DIR/bootstrap/update-thunder.md" "$COMMANDS_DIR/update-thunder.md" "/update-thunder"
echo ""

# --- 2. Bootstrap study directory ---
echo "2. Study workspace ($STUDY_DIR):"
mkdir -p "$STUDY_DIR/.claude/commands" "$STUDY_DIR/.study/tasks/pending" "$STUDY_DIR/.study/tasks/running" "$STUDY_DIR/.study/tasks/done" "$STUDY_DIR/.study/rendered" "$STUDY_DIR/.study/mock-exams" "$STUDY_DIR/.study/research" "$STUDY_DIR/.study-tools" "$STUDY_DIR/.context" "$STUDY_DIR/.study-daemon" "$STUDY_DIR/outputs"

# Copy CLAUDE.md, commands, tools, and architecture docs
cp "$SCRIPT_DIR/CLAUDE.md" "$STUDY_DIR/CLAUDE.md"
echo "  [ok] CLAUDE.md"

CMD_COUNT=0
for cmd_file in "$SCRIPT_DIR"/.claude/commands/*.md; do
    [ -f "$cmd_file" ] || continue
    cp "$cmd_file" "$STUDY_DIR/.claude/commands/$(basename "$cmd_file")"
    CMD_COUNT=$((CMD_COUNT + 1))
done
echo "  [ok] $CMD_COUNT slash commands"

cp "$SCRIPT_DIR/.claude/settings.local.json" "$STUDY_DIR/.claude/settings.local.json"
echo "  [ok] settings.local.json"

cp "$SCRIPT_DIR/.study-tools/render.sh" "$STUDY_DIR/.study-tools/render.sh"
cp "$SCRIPT_DIR/.study-tools/template.html" "$STUDY_DIR/.study-tools/template.html"
chmod +x "$STUDY_DIR/.study-tools/render.sh"
echo "  [ok] .study-tools"

for ctx_file in "$SCRIPT_DIR"/.context/*.md; do
    [ -f "$ctx_file" ] && cp "$ctx_file" "$STUDY_DIR/.context/$(basename "$ctx_file")"
done
echo "  [ok] .context/ architecture docs"

# .gitignore
if [ ! -f "$STUDY_DIR/.gitignore" ]; then
    printf ".study/\noutputs/\n.DS_Store\n*.log\n" > "$STUDY_DIR/.gitignore"
    echo "  [ok] .gitignore"
fi
echo ""

# --- 3. Daemon scripts ---
echo "3. Study daemon:"

for script in study-daemon.sh daily-review.sh on-wake.sh ctl.sh; do
    cp "$SCRIPT_DIR/.study-daemon/$script" "$STUDY_DIR/.study-daemon/$script"
    chmod +x "$STUDY_DIR/.study-daemon/$script"
    echo "  [ok] $script"
done

# Create config if it doesn't exist
mkdir -p "$DAEMON_CONFIG_DIR"
if [ ! -f "$DAEMON_CONFIG_DIR/config" ]; then
    sed "s|\$HOME/study|$STUDY_DIR|g" "$SCRIPT_DIR/.study-daemon/config.example" > "$DAEMON_CONFIG_DIR/config"
    echo "  [ok] Config created at $DAEMON_CONFIG_DIR/config"
else
    echo "  [ok] Config already exists at $DAEMON_CONFIG_DIR/config"
fi
# Copy setup guide files
mkdir -p "$STUDY_DIR/setup"
for setup_file in "$SCRIPT_DIR"/setup/*; do
    [ -f "$setup_file" ] && cp "$setup_file" "$STUDY_DIR/setup/$(basename "$setup_file")"
done
echo "  [ok] setup/ guide files"
echo ""

# --- 3.5. Feynman Research Agent ---
echo "3. Feynman Research Agent:"
if command -v feynman &>/dev/null; then
    echo "  [ok] Feynman is installed ($(feynman --version 2>/dev/null || echo 'version unknown'))"
    if [ -f "$HOME/.feynman/.env" ]; then
        echo "  [ok] Feynman config exists at ~/.feynman/.env"
    else
        echo "  [warn] Feynman installed but not configured. Run: feynman setup"
    fi
else
    echo "  [skip] Feynman not installed (optional)"
    echo "         Install: curl -fsSL https://feynman.is/install | bash"
    echo "         Guide:   setup/feynman.md"
fi
echo ""

# --- 4. Claude Desktop MCP (if Claude Desktop is installed) ---
echo "4. Claude Desktop integration (copy-paste setup):"
CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"

if [ -d "$HOME/Library/Application Support/Claude" ]; then
    if [ -f "$CLAUDE_DESKTOP_CONFIG" ]; then
        # Check if filesystem MCP is already configured
        if grep -q '"filesystem"' "$CLAUDE_DESKTOP_CONFIG" 2>/dev/null; then
            echo "  [ok] Filesystem MCP already configured"
        else
            # Add filesystem MCP server to existing config
            if command -v node &>/dev/null; then
                # Use node to safely merge JSON
                node -e "
                    const fs = require('fs');
                    const config = JSON.parse(fs.readFileSync('$CLAUDE_DESKTOP_CONFIG', 'utf8'));
                    config.mcpServers = config.mcpServers || {};
                    config.mcpServers.filesystem = {
                        command: 'npx',
                        args: ['-y', '@modelcontextprotocol/server-filesystem', '$HOME']
                    };
                    fs.writeFileSync('$CLAUDE_DESKTOP_CONFIG', JSON.stringify(config, null, 2));
                " && echo "  [ok] Filesystem MCP added to Claude Desktop" || echo "  [warn] Could not add MCP config — add manually"
            else
                echo "  [skip] Node.js needed to configure MCP — add manually"
            fi
        fi
    else
        # Create new config
        if command -v node &>/dev/null; then
            echo '{"mcpServers":{"filesystem":{"command":"npx","args":["-y","@modelcontextprotocol/server-filesystem","'"$HOME"'"]}}}' | node -e "
                const fs = require('fs');
                let data = '';
                process.stdin.on('data', d => data += d);
                process.stdin.on('end', () => fs.writeFileSync('$CLAUDE_DESKTOP_CONFIG', JSON.stringify(JSON.parse(data), null, 2)));
            " && echo "  [ok] Claude Desktop config created with filesystem MCP"
        fi
    fi

    # Copy desktop instructions template and replace placeholders with actual paths
    cp "$SCRIPT_DIR/desktop-instructions-template.md" "$STUDY_DIR/desktop-instructions.md"
    sed -i '' "s|\\\$STUDY_DIR|$STUDY_DIR|g" "$STUDY_DIR/desktop-instructions.md" 2>/dev/null || \
    sed -i "s|\\\$STUDY_DIR|$STUDY_DIR|g" "$STUDY_DIR/desktop-instructions.md" 2>/dev/null || true
    echo "  [ok] Desktop instructions at $STUDY_DIR/desktop-instructions.md"
    echo "       (paths pre-filled with $STUDY_DIR)"
    echo ""
    echo "  Next: Create a Project in Claude Desktop and paste the contents of"
    echo "        $STUDY_DIR/desktop-instructions.md as the custom instructions."
    echo ""
    echo "  Config template: setup/claude-desktop-config.example.json"
    echo "  Copy to: ~/Library/Application Support/Claude/claude_desktop_config.json"
    echo "  Replace YOUR_HOME_DIR with: $HOME"
else
    echo "  [skip] Claude Desktop not found"
fi
echo ""

# --- 5. macOS launchd plists ---
echo "5. Background services (macOS):"
if [ "$(uname)" = "Darwin" ]; then
    PLIST_DIR="$HOME/Library/LaunchAgents"
    mkdir -p "$PLIST_DIR"

    # Generate daemon plist
    cat > "$PLIST_DIR/com.study-with-claude.daemon.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.study-with-claude.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$STUDY_DIR/.study-daemon/study-daemon.sh</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>STUDY_DIR</key>
        <string>$STUDY_DIR</string>
        <key>PATH</key>
        <string>$HOME/.local/bin:$HOME/.nvm/versions/node/$(node -v 2>/dev/null || echo "v20.0.0")/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$STUDY_DIR/.study-daemon/daemon-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$STUDY_DIR/.study-daemon/daemon-stderr.log</string>
</dict>
</plist>
PLIST
    echo "  [ok] Task daemon plist"

    # Generate daily review plist
    DAILY_HOUR=$(grep '^DAILY_REVIEW_HOUR=' "$DAEMON_CONFIG_DIR/config" 2>/dev/null | cut -d= -f2 || echo "8")
    DAILY_MIN=$(grep '^DAILY_REVIEW_MINUTE=' "$DAEMON_CONFIG_DIR/config" 2>/dev/null | cut -d= -f2 || echo "0")

    cat > "$PLIST_DIR/com.study-with-claude.daily.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.study-with-claude.daily</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$STUDY_DIR/.study-daemon/daily-review.sh</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$HOME/.local/bin:$HOME/.nvm/versions/node/$(node -v 2>/dev/null || echo "v20.0.0")/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>${DAILY_HOUR:-8}</integer>
        <key>Minute</key>
        <integer>${DAILY_MIN:-0}</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>$STUDY_DIR/.study-daemon/daily-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$STUDY_DIR/.study-daemon/daily-stderr.log</string>
</dict>
</plist>
PLIST
    echo "  [ok] Daily review plist (${DAILY_HOUR:-8}:$(printf '%02d' ${DAILY_MIN:-0}))"

    # Generate wake recovery plist
    cat > "$PLIST_DIR/com.study-with-claude.on-wake.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.study-with-claude.on-wake</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$STUDY_DIR/.study-daemon/on-wake.sh</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>STUDY_DIR</key>
        <string>$STUDY_DIR</string>
        <key>PATH</key>
        <string>$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>WatchPaths</key>
    <array>
        <string>/tmp/com.apple.sleepservices</string>
    </array>
    <key>StandardOutPath</key>
    <string>$STUDY_DIR/.study-daemon/wake-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$STUDY_DIR/.study-daemon/wake-stderr.log</string>
</dict>
</plist>
PLIST
    echo "  [ok] Wake recovery plist"
    echo ""

    # Start services
    echo "6. Starting services..."
    bash "$STUDY_DIR/.study-daemon/ctl.sh" start
else
    echo "  [skip] Not macOS — use cron or systemd to schedule the daemon"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo ""
echo "  Claude Code:"
echo "    1. Add your module folders to $STUDY_DIR (or create symlinks)"
echo "       Example: ln -s ~/Documents/MyCourse $STUDY_DIR/MyCourse"
echo "    2. cd $STUDY_DIR && claude"
echo "    3. /init-session"
echo ""
echo "  Claude Desktop:"
echo "    1. Copy setup/claude-desktop-config.example.json to:"
echo "       ~/Library/Application Support/Claude/claude_desktop_config.json"
echo "       (replace YOUR_HOME_DIR with $HOME)"
echo "    2. Restart Claude Desktop"
echo "    3. Create a Project → paste contents of $STUDY_DIR/desktop-instructions.md"
echo "    4. Start asking questions!"
echo ""
echo "  Feynman (optional — deep cited research):"
echo "    curl -fsSL https://feynman.is/install | bash && feynman setup"
echo "    Then use /deepresearch [topic] in Claude Code"
echo ""
echo "  Daemon control:"
echo "    $STUDY_DIR/.study-daemon/ctl.sh status"
echo "    $STUDY_DIR/.study-daemon/ctl.sh logs"
echo ""
echo "  Full setup guide: $STUDY_DIR/setup/README.md"
echo "  Daemon config:    $DAEMON_CONFIG_DIR/config"
echo ""
