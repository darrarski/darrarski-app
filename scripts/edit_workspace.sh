#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Opens workspace and projects manifest in Xcode. Allows modifying generated workspace structure."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  -h, --help      Show help information."
}

for arg in "$@"; do
  case "$arg" in
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

echo "==> Edit workspace..."
stopwatch start

cd "$ROOT_DIR"
setup_tuist
tuist edit || exit $?

echo "==> \"Edit workspace\" finished in $(stopwatch print)"
stopwatch stop
