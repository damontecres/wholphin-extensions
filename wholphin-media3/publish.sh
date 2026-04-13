#!/usr/bin/env bash
set -e

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
PROJECT_ROOT="$(realpath "${SCRIPT_DIR}/../")"
TARGET_PATH="$PROJECT_ROOT/wholphin-media3/libs"
SETTINGS_FILE="${PROJECT_ROOT}/wholphin-media3/mvn_settings.xml"

media3_version="$(grep "androidx-media3 = " "$PROJECT_ROOT/gradle/libs.versions.toml" | awk -F'"' '{print $2}')"


version="$(git describe --tags --abbrev=0)"
version=${version#v}

version=$version artifactId=decoder-ffmpeg media3_version=$media3_version \
  envsubst '${version} ${artifactId} ${media3_version}' < "${PROJECT_ROOT}/wholphin-media3/pom.template.xml" > "${PROJECT_ROOT}/wholphin-media3/ffmpeg.pom.xml"

version=$version artifactId=decoder-av1 media3_version=$media3_version \
  envsubst '${version} ${artifactId} ${media3_version}' < "${PROJECT_ROOT}/wholphin-media3/pom.template.xml" > "${PROJECT_ROOT}/wholphin-media3/av1.pom.xml"

mvn deploy:deploy-file \
  -s "$SETTINGS_FILE" \
  -Durl="https://maven.pkg.github.com/damontecres/wholphin-extensions" \
  -Dfile="$TARGET_PATH/lib-decoder-ffmpeg-release.aar" \
  -DpomFile="${PROJECT_ROOT}/wholphin-media3/ffmpeg.pom.xml" \
  -DrepositoryId=github

mvn deploy:deploy-file \
  -s "$SETTINGS_FILE" \
  -Durl="https://maven.pkg.github.com/damontecres/wholphin-extensions" \
  -Dfile="$TARGET_PATH/lib-decoder-av1-release.aar" \
  -DpomFile="${PROJECT_ROOT}/wholphin-media3/av1.pom.xml" \
  -DrepositoryId=github
