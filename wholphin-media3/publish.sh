#!/usr/bin/env bash
set -e

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
PROJECT_ROOT="$(realpath "${SCRIPT_DIR}/../")"
TARGET_PATH="$PROJECT_ROOT/wholphin-media3/libs"
SETTINGS_FILE="${PROJECT_ROOT}/wholphin-media3/mvn_settings.xml"

version="$(git describe --tags --abbrev=0)"
version=${version#v}

mvn deploy:deploy-file \
  -s "$SETTINGS_FILE" \
  -Durl="https://maven.pkg.github.com/damontecres/wholphin-extensions" \
  -Dfile="$TARGET_PATH/lib-decoder-ffmpeg-release.aar" \
  -DgroupId=com.github.damontecres.wholphin.media3 \
  -DartifactId=decoder-ffmpeg \
  -Dversion="$version" \
  -DrepositoryId=github

mvn deploy:deploy-file \
  -s "$SETTINGS_FILE" \
  -Durl="https://maven.pkg.github.com/damontecres/wholphin-extensions" \
  -Dfile="$TARGET_PATH/lib-decoder-av1-release.aar" \
  -DgroupId=com.github.damontecres.wholphin.media3 \
  -DartifactId=decoder-av1 \
  -Dversion="$version" \
  -DrepositoryId=github
