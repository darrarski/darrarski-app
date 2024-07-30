#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Fetches and installs Swift Package Manager dependencies. Should be run before generating the workspace."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  -u, --update    Update dependencies."
  echo "  -h, --help      Show help information."
}

UPDATE=0

for arg in "$@"; do
  case "$arg" in
    -u|--update)
      UPDATE=1;;
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

echo "==> Install SPM dependencies..."
stopwatch start

cd "$ROOT_DIR"
setup_tuist

if [[ $UPDATE -eq 1 ]]; then
  tuist install -u || exit $?
else
  tuist install || exit $?
fi

echo "==> \"Install SPM dependencies\" finished in $(stopwatch print)"
stopwatch stop
