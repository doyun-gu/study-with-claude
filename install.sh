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

# --- 2. Daemon scripts ---
echo "2. Study daemon:"
mkdir -p "$STUDY_DIR/.study-daemon" "$STUDY_DIR/.study/tasks/pending" "$STUDY_DIR/.study/tasks/running" "$STUDY_DIR/.study/tasks/done"

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
echo ""

# --- 3. Claude Desktop MCP (if Claude Desktop is installed) ---
echo "3. Claude Desktop integration:"
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

    # Copy desktop instructions template
    cp "$SCRIPT_DIR/desktop-instructions-template.md" "$STUDY_DIR/desktop-instructions.md"
    sed -i '' "s|\$HOME/study|$STUDY_DIR|g" "$STUDY_DIR/desktop-instructions.md" 2>/dev/null || \
    sed -i "s|\$HOME/study|$STUDY_DIR|g" "$STUDY_DIR/desktop-instructions.md" 2>/dev/null || true
    echo "  [ok] Desktop instructions template at $STUDY_DIR/desktop-instructions.md"
    echo ""
    echo "  Next: Create a Project in Claude Desktop and paste the contents of"
    echo "        $STUDY_DIR/desktop-instructions.md as the custom instructions."
else
    echo "  [skip] Claude Desktop not found"
fi
echo ""

# --- 4. macOS launchd plists ---
echo "4. Background services (macOS):"
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
    echo "5. Starting services..."
    bash "$STUDY_DIR/.study-daemon/ctl.sh" start
else
    echo "  [skip] Not macOS — use cron or systemd to schedule the daemon"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Installation complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Claude Code (terminal):"
echo "  cd $STUDY_DIR"
echo "  claude"
echo "  /init-session"
echo ""
echo "Claude Desktop:"
echo "  1. Restart Claude Desktop"
echo "  2. Create a Project → paste contents of $STUDY_DIR/desktop-instructions.md"
echo "  3. Start asking questions!"
echo ""
echo "Daemon control:"
echo "  $STUDY_DIR/.study-daemon/ctl.sh status"
echo "  $STUDY_DIR/.study-daemon/ctl.sh logs"
echo ""
echo "Config: $DAEMON_CONFIG_DIR/config"
echo ""
