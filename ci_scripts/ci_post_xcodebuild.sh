#!/usr/bin/env bash
source "$(readlink -f $0 | xargs dirname | xargs dirname)/scripts/_shared.sh"

# When deploying...
if [[ $CI_WORKFLOW == "Deploy" ]]; then
  PROJECT_PATH="$ROOT_DIR/Projects/App/App.xcodeproj/project.pbxproj"
  MARKETING_VERSION=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ${PROJECT_PATH})
  BUILD_TAG=v${MARKETING_VERSION}-${CI_BUILD_NUMBER}
  TESTFLIGHT_DIR="$ROOT_DIR/TestFlight"
  WHAT_TO_TEST_PATH="$TESTFLIGHT_DIR/WhatToTest.en-US.txt"

  # Add and push build tag
  echo "==> Adding git tag: ${BUILD_TAG}"
  git tag -a -f -m "" ${BUILD_TAG}
  git push https://darrarski:${GITHUB_PAT}@github.com/darrarski/darrarski-app.git ${BUILD_TAG}
  
  # Generate WhatToTest file from commits since previous tag
  mkdir -p "$TESTFLIGHT_DIR"
  git fetch --unshallow --tags
  git log \
    $(git describe --tags --abbrev=0 HEAD~1)..HEAD \
    --pretty=format:'- %s' \
    --first-parent \
    > "$WHAT_TO_TEST_PATH"
  echo "" >> "$WHAT_TO_TEST_PATH"
  echo "- More info: https://github.com/darrarski/darrarski-app/releases/tag/${BUILD_TAG}" \
    >> "$WHAT_TO_TEST_PATH"
  echo "==> What To Test:"
  cat "$WHAT_TO_TEST_PATH"

  # Use TelemetryDeckAppID secret from workflow environment variable
  echo "${TelemetryDeckAppID}" > "$ROOT_DIR/Projects/App/app-secrets/Sources/AppSecrets/Secrets/TelemetryDeckAppID"
fi
