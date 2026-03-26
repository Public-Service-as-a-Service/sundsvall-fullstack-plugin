#!/bin/bash
# Dept44 pattern check hook — runs on PostToolUse for Write|Edit
# Reads JSON from stdin, extracts file_path, checks Java files for anti-patterns.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only check .java files
if [[ -z "$FILE_PATH" || "$FILE_PATH" != *.java ]]; then
  exit 0
fi

# Skip if file doesn't exist (e.g. deleted)
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

WARNINGS=""

# Check for @Autowired (should use constructor injection)
if grep -qn '@Autowired' "$FILE_PATH"; then
  WARNINGS+="WARNING: @Autowired found — use constructor injection instead.\n"
fi

# Check for Lombok annotations
if grep -qnE '@(Data|Builder|Getter|Setter|AllArgsConstructor|NoArgsConstructor|RequiredArgsConstructor|Value|With|ToString|EqualsAndHashCode)' "$FILE_PATH"; then
  WARNINGS+="WARNING: Lombok annotation found — dept44 does not use Lombok. Use manual getters/setters, create()/with*() builders.\n"
fi

# Check for org.zalando.problem (should be se.sundsvall.dept44.problem)
if grep -qn 'org\.zalando\.problem' "$FILE_PATH"; then
  WARNINGS+="WARNING: org.zalando.problem import found — use se.sundsvall.dept44.problem instead.\n"
fi

# Check for wildcard imports
if grep -qnE '^import .*\.\*;' "$FILE_PATH"; then
  WARNINGS+="WARNING: Wildcard import found — use explicit imports.\n"
fi

# Check for missing @CircuitBreaker on @Repository or @FeignClient classes
if grep -qE '@(Repository|FeignClient)' "$FILE_PATH"; then
  if ! grep -q '@CircuitBreaker' "$FILE_PATH"; then
    WARNINGS+="WARNING: @Repository or @FeignClient without @CircuitBreaker — add @CircuitBreaker annotation.\n"
  fi
fi

if [[ -n "$WARNINGS" ]]; then
  # Use JSON additionalContext so Claude actually sees the warnings
  # (PostToolUse stdout is only visible in verbose mode unless structured as JSON)
  ESCAPED_WARNINGS=$(echo -e "$WARNINGS" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":${ESCAPED_WARNINGS}}}"
fi
