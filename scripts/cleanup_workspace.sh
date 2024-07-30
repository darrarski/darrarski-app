#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Cleans up workspace. Removes generated files. Removes ignored and unstaged files."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  --files         Remove ignored and unstaged files."
  echo "  --tuist         Remove Tuist build files."
  echo "  -a, --all       Remove all of the above."
  echo "  -f, --force     Perform clean up (dry-run if not provided)."
  echo "  -h, --help      Show help information."
}

FILES=0
TUIST=0
ALL=0
FORCE=0

if [[ $# -lt 1 ]]; then
  help
  exit 0
fi

for arg in "$@"; do
  case "$arg" in
    --files)
      FILES=1;;
    --tuist)
      TUIST=1;;
    -a|--all)
      ALL=1;;
    -f|--force)
      FORCE=1;;
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

function git_clean {
  local command="git clean -d -x -f -f"
  if [[ ! $FORCE -eq 1 ]]; then
    local command="$command -n"
  fi
  eval "$command $@" || exit $?
}

echo "==> Clean up workspace..."
stopwatch start

if [[ ! $FORCE -eq 1 ]]; then
  echo "Dry-run. Run again with --force flag to perform clean up."
fi

if [[ $ALL -eq 1 || $FILES -eq 1 ]]; then
  echo "==> Ignored and unstaged files..."
  cd "$ROOT_DIR"
  git_clean -e "/Tuist"
fi

if [[ $ALL -eq 1 || $TUIST -eq 1 ]]; then
  echo "==> Tuist..."
  cd "$ROOT_DIR"
  git_clean "./Tuist"
fi

if [[ ! $FORCE -eq 1 ]]; then
  echo "Dry-run. Run again with --force flag to perform clean up."
fi

echo "==> \"Clean up workspace\" finished in $(stopwatch print)"
stopwatch stop
