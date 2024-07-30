#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname)/_shared.sh"

function help {
  echo "OVERVIEW: Installs Mise which is used to fetch development tools."
  echo ""
  echo "USAGE: $(basename $(readlink -f $0)) [options]"
  echo ""
  echo "OPTIONS:"
  echo "  -f, --force     Force re-install."
  echo "  -b, --binary    Download latest binary release instead of using install script."
  echo "  -h, --help      Show help information."
}

BINARY=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    -f|--force)
      FORCE=1;;
    -b|--binary)
      BINARY=1;;
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

function is_mise_installed {
  mise version &> /dev/null
  if [[ $? -eq 0 ]]; then
    echo 1
  else
    "$MISE_INSTALL_PATH" version &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo 1
    else
      echo 0
    fi
  fi
}

function get_arch {
  local musl=""
  if type ldd >/dev/null 2>/dev/null; then
    local libc=$(ldd /bin/ls | grep 'musl' | head -1 | cut -d ' ' -f1)
    if [ -n "$libc" ]; then
      local musl="-musl"
    fi
  fi
  local arch="$(uname -m)"
  if [ "$arch" = x86_64 ]; then
    echo "x64$musl"
  elif [ "$arch" = aarch64 ] || [ "$arch" = arm64 ]; then
    echo "arm64$musl"
  elif [ "$arch" = armv7l ]; then
    echo "armv7$musl"
  else
    echo "Unsupported architecture: $arch"
    exit 1
  fi
}

function download_mise_binary {
  echo "==> Downloading mise binary..."
  local url="https://mise.jdx.dev/mise-latest-macos-$(get_arch)"
  mkdir -p "$(echo "$MISE_INSTALL_PATH" | xargs dirname)"
  curl -f "$url" > "$MISE_INSTALL_PATH" || exit $?
  chmod +x "$MISE_INSTALL_PATH" || exit $?
}

function install_mise {
  echo "==> Installing mise..."
  export MISE_INSTALL_PATH="$MISE_INSTALL_PATH"
  export MISE_QUIET=1
  curl -f https://mise.run | sh
  if [[ ! $? -eq 0 ]]; then
    echo "Could not install mise. Try running $(basename $(readlink -f $0)) with --binary flag as a workaround."
    exit 1
  fi
}

if [[ $FORCE -eq 1 || ! $(is_mise_installed) -eq 1 ]]; then
  echo "==> Install mise..."
  stopwatch start

  if [[ $BINARY -eq 1 ]]; then
    download_mise_binary
  else
    install_mise
  fi

  echo "==> \"Install mise\" finished in $(stopwatch print)"
  stopwatch stop
fi
