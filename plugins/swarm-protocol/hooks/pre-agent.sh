#!/bin/bash
# Pre-Agent hook: Protocol enforcer for swarm pipeline
#
# What it does:
# 1. Checks if this is a swarm agent (name starts with "swarm-")
# 2. If yes: validates no role assignment, injects predecessor artifacts + 97-dev principles
# 3. If no: passes through without modification

input=$(cat)

# Extract agent name from tool input
agent_name=$(echo "$input" | jq -r '.tool_input.name // ""')

# Only activate for swarm pipeline agents
if [[ "$agent_name" != swarm-* ]]; then
  echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse"}}'
  exit 0
fi

prompt=$(echo "$input" | jq -r '.tool_input.prompt // ""')

# --- Check 1: Block explicit role assignments ---
role_patterns='(you are a |act as a |your role is |ты —|твоя роль|you are the |play the role)'
if echo "$prompt" | grep -qiE "$role_patterns"; then
  cat <<'DENY'
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "[Swarm Protocol Violation] Do not assign roles to swarm agents. Give them the mission and predecessor artifacts. They choose their own role. Rewrite the prompt: remove role assignment, add 'Choose how you can best contribute based on what predecessors have done.'"
  }
}
DENY
  exit 0
fi

# --- Load 97-dev principles ---
plugin_root="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}"
principles=""
if [ -f "$plugin_root/principles.md" ]; then
  principles=$(cat "$plugin_root/principles.md")
fi

# --- Build principles block ---
principles_block=""
if [ -n "$principles" ]; then
  principles_block="

=== DEVELOPMENT PRINCIPLES ===
${principles}
=== END PRINCIPLES ===
"
fi

# --- Pipeline state directory (flat — conductor manages cleanup) ---
pipeline_dir="${CLAUDE_PLUGIN_DATA:-/tmp}/swarm-pipeline"

if [ -d "$pipeline_dir" ] && [ "$(ls -A "$pipeline_dir" 2>/dev/null)" ]; then
  # Count existing artifacts
  artifact_count=$(ls "$pipeline_dir"/*.json 2>/dev/null | wc -l | tr -d ' ')

  # Build artifacts summary
  artifacts=""
  for f in "$pipeline_dir"/*.json; do
    [ -f "$f" ] || continue
    step=$(jq -r '.step' "$f" 2>/dev/null)
    chosen_role=$(jq -r '.chosen_role' "$f" 2>/dev/null)
    summary=$(jq -r '.summary' "$f" 2>/dev/null)
    artifacts="${artifacts}
--- Agent #${step} (self-selected role: ${chosen_role}) ---
${summary}
"
  done

  # Build the protocol injection WITH principles
  protocol_injection="${principles_block}
=== SWARM PROTOCOL CONTEXT ===
You are agent #$((artifact_count + 1)) in a sequential pipeline.
${artifact_count} agent(s) have already contributed to this mission.

PREDECESSOR ARTIFACTS:
${artifacts}

INSTRUCTIONS:
1. Review what predecessors have done
2. Decide how YOU can best contribute (choose your own role/approach)
3. If you cannot meaningfully improve the current result, respond with exactly: PASS: [reason]
4. Begin your response with: ROLE: [what you chose to be] — then do your work
5. Be specific and concrete. Build on predecessors' work, don't repeat it.
6. Follow the Development Principles above in all code you write or review.

SCOPE DISCIPLINE — THIS IS CRITICAL:
- Make ONE focused contribution. Do not try to do everything.
- You are part of a pipeline. Others come after you. Leave them meaningful work.
- If you analyze — do not also design. If you design — do not also implement.
- If you implement — do not also write tests. If you review — do not also fix.
- Maximum: 3 files created/modified. If you need more, you're doing too much.
- End your response with:
  HANDOFF: [what you deliberately left for subsequent agents]
  This is mandatory. If you have nothing to hand off, say PASS instead of contributing.
=== END SWARM PROTOCOL ==="

  # Append protocol context to the existing prompt
  updated_prompt="${prompt}${protocol_injection}"

  # Use updatedInput to modify the prompt
  echo "$input" | jq --arg new_prompt "$updated_prompt" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "updatedInput": (.tool_input + {"prompt": $new_prompt})
    }
  }'
  exit 0
fi

# First agent in pipeline — add minimal protocol header WITH principles
first_agent_injection="${principles_block}
=== SWARM PROTOCOL CONTEXT ===
You are the FIRST agent in a sequential pipeline. No predecessors yet.

INSTRUCTIONS:
1. You have full freedom to choose your approach and role
2. Begin your response with: ROLE: [what you chose to be] — then do your work
3. Be thorough — subsequent agents will build on your output
4. Focus on what will be most valuable as a foundation for others
5. Follow the Development Principles above in all code you write or review.

SCOPE DISCIPLINE — THIS IS CRITICAL:
- Make ONE focused contribution. Do not try to do everything.
- You are the first in a pipeline. Others come after you. Leave them meaningful work.
- Pick ONE phase: analyze OR design OR implement OR test OR review. Not multiple.
- Maximum: 3 files created/modified. If you need more, you're doing too much.
- End your response with:
  HANDOFF: [what you deliberately left for subsequent agents]
  This is mandatory. A good handoff is specific: name files, describe gaps, suggest next steps.
=== END SWARM PROTOCOL ==="

updated_prompt="${prompt}${first_agent_injection}"

echo "$input" | jq --arg new_prompt "$updated_prompt" '{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "updatedInput": (.tool_input + {"prompt": $new_prompt})
  }
}'
exit 0
