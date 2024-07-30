# This file should be sourced into current shell in order to setup dev-tools:
# $ source _setup_devtools.sh

source "$(readlink -f $0 | xargs dirname)/_shared.sh"

echo "==> Setup dev-tools..."
stopwatch start
setup_mise
setup_tuist
echo "==> \"Setup dev-tools\" finished in $(stopwatch print)"
stopwatch stop
