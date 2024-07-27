#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname | xargs dirname)/scripts/_shared.sh"

# Skip validation of third-party swift macros
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

# Setup dev-tools
export COLORBT_SHOW_HIDDEN=1
export RUST_BACKTRACE=full
setup_mise
mise install tuist || exit $?
echo "Tuist v$(mise x -- tuist version) ($(mise which tuist))"

# Setup Xcode workspace
"$ROOT_DIR/scripts/setup_for_development.sh" || exit $?
