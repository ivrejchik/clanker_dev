#!/bin/bash
# Post-Agent hook: Artifact collector + scope guard for swarm pipeline
#
# What it does:
# 1. Checks if this was a swarm agent (name starts with "swarm-")
# 2. Extracts: chosen role, HANDOFF section, file change count
# 3. Saves as numbered artifact for next agents
# 4. Warns if agent violated scope discipline (too many files, no handoff)

input=$(cat)

agent_name=$(echo "$input" | jq -r '.tool_input.name // ""')

# Only activate for swarm pipeline agents
if [[ "$agent_name" != swarm-* ]]; then
  exit 0
fi

pipeline_dir="${CLAUDE_PLUGIN_DATA:-/tmp}/swarm-pipeline"
mkdir -p "$pipeline_dir"

# Get agent output
result=$(echo "$input" | jq -r '.tool_result // ""')

# Determine step number
existing=$(ls "$pipeline_dir"/*.json 2>/dev/null | wc -l | tr -d ' ')
step=$((existing + 1))

# Extract chosen role from output (looks for "ROLE: xxx" pattern)
chosen_role=$(echo "$result" | grep -oiE 'ROLE:\s*[^\n]+' | head -1 | sed 's/ROLE:\s*//')
if [ -z "$chosen_role" ]; then
  chosen_role="unspecified"
fi

# Check if agent passed
is_pass="false"
if echo "$result" | grep -qiE '^PASS:'; then
  is_pass="true"
fi

# Extract HANDOFF section
handoff=$(echo "$result" | sed -n '/^HANDOFF:/,$ p' | head -10)
has_handoff="true"
if [ -z "$handoff" ] && [ "$is_pass" = "false" ]; then
  has_handoff="false"
fi

# Count file operations mentioned in output (rough heuristic)
# Look for patterns like "Created file", "Modified file", "wrote to", Edit/Write tool mentions
file_ops=$(echo "$result" | grep -ciE '(created|modified|wrote|updated|edited|new file|Write tool|Edit tool).*\.(ts|js|py|go|rs|java|tsx|jsx|css|html|json|yaml|yml|md|sql|sh)')
scope_warning=""
if [ "$file_ops" -gt 5 ] && [ "$is_pass" = "false" ]; then
  scope_warning="[SCOPE WARNING] Agent touched ~${file_ops} files. Pipeline protocol limits to 3. This agent may have done too much solo work — subsequent agents may have less to contribute."
fi

handoff_warning=""
if [ "$has_handoff" = "false" ]; then
  handoff_warning="[HANDOFF MISSING] Agent did not include a HANDOFF section. Without explicit handoff, next agents don't know what's left to do. Quality of pipeline may degrade."
fi

# Truncate result for artifact storage (keep first 4000 chars)
truncated_result=$(echo "$result" | head -c 4000)

# Save artifact with metadata
jq -n \
  --arg step "$step" \
  --arg agent_name "$agent_name" \
  --arg chosen_role "$chosen_role" \
  --arg is_pass "$is_pass" \
  --arg has_handoff "$has_handoff" \
  --arg handoff "$handoff" \
  --arg file_ops "$file_ops" \
  --arg summary "$truncated_result" \
  --arg timestamp "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '{
    step: ($step | tonumber),
    agent_name: $agent_name,
    chosen_role: $chosen_role,
    is_pass: ($is_pass == "true"),
    has_handoff: ($has_handoff == "true"),
    handoff: $handoff,
    file_ops: ($file_ops | tonumber),
    summary: $summary,
    timestamp: $timestamp
  }' > "$pipeline_dir/${step}_artifact.json"

# Log to pipeline status
echo "{\"step\":$step,\"role\":\"$chosen_role\",\"pass\":$is_pass,\"files\":$file_ops,\"handoff\":$has_handoff}" >> "$pipeline_dir/pipeline.log"

# Build warnings for conductor (written to separate file so conductor can check)
warnings=""
[ -n "$scope_warning" ] && warnings="${warnings}${scope_warning}\n"
[ -n "$handoff_warning" ] && warnings="${warnings}${handoff_warning}\n"

if [ -n "$warnings" ]; then
  echo -e "$warnings" > "$pipeline_dir/${step}_warnings.txt"
fi

exit 0
