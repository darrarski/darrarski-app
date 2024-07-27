#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname | xargs dirname)/scripts/_shared.sh"

# Skip validation of third-party swift macros
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES

# Install mise
"$ROOT_DIR/scripts/install_mise.sh" --binary || exit $?

# Setup Xcode workspace
"$ROOT_DIR/scripts/setup_for_development.sh" || exit $?
