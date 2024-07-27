ROOT_DIR="$(readlink -f $0 | xargs dirname | xargs dirname)"
MISE_INSTALL_PATH=${MISE_INSTALL_PATH:-"$HOME/.local/bin/mise"}

function setup_mise {
  sh "$ROOT_DIR/scripts/install_mise.sh" || exit $?
  export MISE_YES=1
  export MISE_NOT_FOUND_AUTO_INSTALL=true
  mise version &> /dev/null
  if [[ $? -eq 0 ]]; then
    local mise_bin="mise"
  else
    local mise_bin="$MISE_INSTALL_PATH"
  fi
  eval "$("$mise_bin" activate --shims)" || exit $?
}
