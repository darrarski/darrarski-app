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

OUTPUT_DIR="$ROOT_DIR/web/assets"
OUTPUT_PATH="$OUTPUT_DIR/graph.png"
OUTPUT_TESTS_PATH="$OUTPUT_DIR/graph-tests.png"
OUTPUT_EXTERNAL_PATH="$OUTPUT_DIR/graph-external.png"

tuist graph \
  --no-skip-test-targets \
  --skip-external-dependencies \
  --format png \
  --no-open \
  --algorithm dot \
  --path "$ROOT_DIR" \
  --output-path "$OUTPUT_DIR" \
|| exit $?

mv -f "$OUTPUT_PATH" "$OUTPUT_TESTS_PATH" || exit $?

echo "Generated: $OUTPUT_TESTS_PATH"

tuist graph \
  --skip-test-targets \
  --no-skip-external-dependencies \
  --format png \
  --no-open \
  --algorithm dot \
  --path "$ROOT_DIR" \
  --output-path "$OUTPUT_DIR" \
|| exit $?

mv -f "$OUTPUT_PATH" "$OUTPUT_EXTERNAL_PATH" || exit $?

echo "Generated: $OUTPUT_EXTERNAL_PATH"

tuist graph \
  --skip-test-targets \
  --skip-external-dependencies \
  --format png \
  --no-open \
  --algorithm dot \
  --path "$ROOT_DIR" \
  --output-path "$OUTPUT_DIR" \
|| exit $?

echo "Generated: $OUTPUT_PATH"

if [[ $OPEN == 1 ]]; then
  open "$OUTPUT_EXTERNAL_PATH"
  open "$OUTPUT_TESTS_PATH"
  open "$OUTPUT_PATH"
fi
