#!/usr/bin/env bash
# StudyBuddy runner - sets up BoxLang's environment, then runs whatever you pass.
#   ./run.sh test              offline test suite (no API key needed)
#   ./run.sh demo              5 demo scenarios against the live provider
#   ./run.sh <file.bxs>        any BoxLang script, with config + .env loaded
set -euo pipefail
cd "$(dirname "$0")"

export JAVA_HOME="${JAVA_HOME:-/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home}"
export PATH="$JAVA_HOME/bin:$HOME/.bvm/current/bin:/opt/homebrew/bin:$PATH"

# BoxLang reads the process environment, not .env, so load it here.
[ -f .env ] && { set -a; . ./.env; set +a; }

case "${1:-test}" in
  test) exec boxlang tests/run-tests.bxs ;;                        # no --bx-config: uses the mock provider
  demo) exec boxlang --bx-config ./boxlang.json demo.bxs ;;
  *)    exec boxlang --bx-config ./boxlang.json "$@" ;;
esac
