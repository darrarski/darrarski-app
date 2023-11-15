#!/bin/sh

realpath() {
  local path=`eval echo "$1"`
  local folder=$(dirname "$path")
  echo $(cd "$folder"; pwd)/$(basename "$path"); 
}

if [[ $CI_WORKFLOW == "Deploy" ]]; then
  cd "$(dirname $(realpath $0))"

  PROJECT_PATH="../project/DarrarskiApp.xcodeproj/project.pbxproj"
  MARKETING_VERSION=$(sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ${PROJECT_PATH})
  BUILD_TAG=v${MARKETING_VERSION}-${CI_BUILD_NUMBER}
  TESTFLIGHT_DIR_PATH=../TestFlight
  WHAT_TO_TEST_PATH=$TESTFLIGHT_DIR_PATH/WhatToTest.en-US.txt

  # Add and push build tag:
  echo "Adding git tag: ${BUILD_TAG}"
  git tag -a -f -m "" ${BUILD_TAG}
  git push https://darrarski:${GITHUB_PAT}@github.com/darrarski/darrarski-app.git ${BUILD_TAG}

  # Generate WhatToTest file from commits since previous tag:
  mkdir $TESTFLIGHT_DIR_PATH
  git fetch --unshallow --tags
  git log \
    $(git describe --tags --abbrev=0 HEAD~1)..HEAD \
    --pretty=format:'- %s' \
    --first-parent \
    > $WHAT_TO_TEST_PATH
  echo "\n- More info: https://github.com/darrarski/darrarski-app/releases/tag/${BUILD_TAG}" \
    >> $WHAT_TO_TEST_PATH
  echo "What To Test:"
  cat $WHAT_TO_TEST_PATH

  # Use TelemetryDeckAppID secret from workflow environment variable
  echo "${TelemetryDeckAppID}" > ../app/Sources/AppFeature/Secrets/TelemetryDeckAppID
fi

# Skip validation of third-party swift macros
defaults write com.apple.dt.Xcode IDESkipMacroFingerprintValidation -bool YES
