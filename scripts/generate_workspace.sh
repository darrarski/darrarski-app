#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Generates Xcode workspace and projects."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  -o, --open      Open Xcode workspace."
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

cd "$ROOT_DIR"
setup_mise
mise x -- tuist generate --no-open || exit $?

if [[ $OPEN -eq 1 ]]; then
  "$ROOT_DIR/scripts/open_workspace.sh" || exit $?
fi
