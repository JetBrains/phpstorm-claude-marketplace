#!/bin/bash
# PostToolUse hook: Run PHP inspections after file edits

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

[[ ! "$file_path" =~ \.(php|phtml|php[345]|phps)$ ]] && exit 0

PROJECT_PATH="${CLAUDE_PROJECT_DIR:-}"
[[ -z "$PROJECT_PATH" ]] && exit 0

PORT=$(cat "$HOME/.claude/phpstorm/phpstormmcp.port" 2>/dev/null)
[[ -z "$PORT" ]] && exit 0

relative_path="${file_path#"$PROJECT_PATH"/}"
request_id="hook-$$"

init_response=$(curl -s -i -X POST "http://127.0.0.1:$PORT/stream" \
    -H "Content-Type: application/json" \
    -H "IJ_MCP_SERVER_PROJECT_PATH: $PROJECT_PATH" \
    -d "$(jq -n --arg id "$request_id" '{jsonrpc:"2.0", id:$id, method:"initialize", params:{protocolVersion:"2024-11-05", capabilities:{}, clientInfo:{name:"get_inspections", version:"1.0"}}}')" \
    --max-time 15)

SESSION_ID=$(echo "$init_response" | grep -i "^mcp-session-id:" | tr -d '\r\n' | cut -d' ' -f2)
[[ -z "$SESSION_ID" ]] && exit 0

result=$(curl -s -X POST "http://127.0.0.1:$PORT/stream" \
    -H "Content-Type: application/json" \
    -H "IJ_MCP_SERVER_PROJECT_PATH: $PROJECT_PATH" \
    -H "mcp-session-id: $SESSION_ID" \
    -d "$(jq -n --arg id "$request_id" --arg path "$relative_path" '{jsonrpc:"2.0", id:$id, method:"tools/call", params:{name:"get_inspections", arguments:{filePath:$path, minSeverity:"WEAK_WARNING", timeout:10000}}}')" \
    --max-time 15 | jq -r '.result.content[0].text // empty')

[[ -z "$result" ]] && exit 0

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":$(echo "$result" | jq -Rs '.')}}"
