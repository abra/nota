#!/bin/bash

set -e

PASS=0
FAIL=0

run() {
  local label=$1
  local cmd=$2
  local dir=$3

  echo ""
  echo "▶ $label"
  if (cd "$dir" && eval "$cmd" 2>&1); then
    PASS=$((PASS + 1))
  else
    FAIL=$((FAIL + 1))
  fi
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

run "shared"                       "dart test test/"    "$SCRIPT_DIR/packages/shared"
run "note_repository"              "flutter test test/" "$SCRIPT_DIR/packages/note_repository"
run "preferences_service"          "flutter test test/" "$SCRIPT_DIR/packages/preferences_service"
run "component_library"            "flutter test test/" "$SCRIPT_DIR/packages/component_library"
run "monitoring"                   "flutter test test/" "$SCRIPT_DIR/packages/monitoring"
run "note_list"                    "flutter test test/" "$SCRIPT_DIR/packages/features/note_list"
run "note_details"                 "flutter test test/" "$SCRIPT_DIR/packages/features/note_details"
run "preferences_menu"             "flutter test test/" "$SCRIPT_DIR/packages/features/preferences_menu"

echo ""
echo "────────────────────────────"
echo "  passed: $PASS  failed: $FAIL"
echo "────────────────────────────"

[ $FAIL -eq 0 ]
