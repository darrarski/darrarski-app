ROOT_DIR="$(readlink -f $0 | xargs dirname | xargs dirname)"
MISE_INSTALL_PATH=${MISE_INSTALL_PATH:-"$HOME/.local/bin/mise"}

# Setup Mise. Install if needed and activate in current shell.
# This function performs setup once per shell, unless called with --force.
function setup_mise {
  if [[ ! -z $SETUP_MISE_DONE && $1 != "--force" ]]; then return; fi
  sh "$ROOT_DIR/scripts/install_mise.sh" || exit $?
  export MISE_YES=1
  mise version &> /dev/null
  if [[ $? -eq 0 ]]; then
    local mise_bin="mise"
  else
    local mise_bin="$MISE_INSTALL_PATH"
  fi
  eval "$("$mise_bin" activate --shims)" || exit $?
  echo "Mise $(mise --version)"
  export SETUP_MISE_DONE=1
}

# Setup Tuist. Use Mise to install it.
# This function performs setup once per shell, unless called with --force.
function setup_tuist {
  if [[ ! -z $SETUP_TUIST_DONE && $1 != "--force" ]]; then return; fi
  setup_mise
  mise install tuist || exit $?
  echo "Tuist v$(mise x -- tuist version) ($(mise which tuist))"
  export SETUP_TUIST_DONE=1
}

# Measure time
# Usage: stopwatch [start|stop|print]
function stopwatch {
  case "$1" in
    start)
      # start new stopwatch
      STOPWATCH+=($(date -u +%s))
      ;;
    stop)
      # stop last started stopwatch
      if [[ ${#STOPWATCH[@]} > 0 ]]; then
        unset STOPWATCH[$((${#STOPWATCH[@]}-1))]
      fi
      ;;
    print)
      # print last started (but not stopped) stopwatch's elapsed time
      if [[ ! -z $STOPWATCH ]]; then
        local start=${STOPWATCH[$((${#STOPWATCH[@]}-1))]}
        local now=$(date -u +%s)
        local elapsed=$((now-start))
        local hours=$((elapsed/3600))
        local minutes=$((elapsed%3600/60))
        local seconds=$((elapsed%60))
        printf '%.0f:%2.0f:%2.0f' $hours $minutes $seconds | tr ' ' '0'
      fi
      ;;
  esac
}
