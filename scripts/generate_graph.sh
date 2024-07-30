#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Generates dependency graph for the workspace."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  -o, --open      Open the graph after generation."
  echo "  -h, --help      Show help information."
}

OPEN=0

for arg in "$@"; do
  case "$arg" in
    -o|--open)
      OPEN=1;;
    -h|--help)
      help
      exit 0;;
    *)
      echo "Unknown argument: $arg"
      echo ""
      help
      exit 1;;
  esac
done

setup_tuist

tuist graph \
  --skip-test-targets \
  --skip-external-dependencies \
  --format png \
  $(if [[ $OPEN == 1 ]]; then echo "--open"; else echo "--no-open"; fi) \
  --algorithm dot \
  --path "$ROOT_DIR" \
  --output-path "$ROOT_DIR/web/assets" \
|| exit $?
