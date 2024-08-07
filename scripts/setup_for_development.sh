#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Prepares everything needed for development."
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

echo "==> Setup for development..."
stopwatch start

source "$ROOT_DIR/scripts/_setup_devtools.sh" || exit $?
"$ROOT_DIR/scripts/install_spm_dependencies.sh" || exit $?
"$ROOT_DIR/scripts/generate_workspace.sh" || exit $?

echo "==> \"Setup for development\" finished in $(stopwatch print)"
stopwatch stop

if [[ $OPEN -eq 1 ]]; then
  "$ROOT_DIR/scripts/open_workspace.sh" || exit $?
fi
