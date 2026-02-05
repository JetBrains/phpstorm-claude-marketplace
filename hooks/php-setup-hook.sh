#!/bin/bash
# SessionStart hook: Store PhpStorm MCP port in user-level state file

PORT=$(claude mcp get phpstorm 2>/dev/null | grep -oE '(localhost|127\.0\.0\.1):([0-9]+)' | sed 's/.*://' | head -1)
[[ -z "$PORT" ]] && exit 0

STATE_DIR="$HOME/.claude/phpstorm"
mkdir -p "$STATE_DIR"
echo "$PORT" > "$STATE_DIR/phpstormmcp.port"
