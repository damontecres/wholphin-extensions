#!/usr/bin/env bash
set -e

MODULES=(ffmpeg av1 flac opus)

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
PROJECT_ROOT="$(realpath "${SCRIPT_DIR}/../")"
TARGET_PATH="$PROJECT_ROOT/wholphin-media3/libs"
SETTINGS_FILE="${PROJECT_ROOT}/wholphin-media3/mvn_settings.xml"

media3_version="$(grep "androidx-media3 = " "$PROJECT_ROOT/gradle/libs.versions.toml" | awk -F'"' '{print $2}')"

version="$(git describe --tags --abbrev=0)"
version=${version#v}

for module in "${MODULES[@]}"; do
  version=$version artifactId="decoder-${module}" media3_version=$media3_version \
    envsubst '${version} ${artifactId} ${media3_version}' < "${PROJECT_ROOT}/wholphin-media3/pom.template.xml" > "${PROJECT_ROOT}/wholphin-media3/${module}.pom.xml"
done

for module in "${MODULES[@]}"; do
  mvn deploy:deploy-file \
    -s "$SETTINGS_FILE" \
    -Durl="https://maven.pkg.github.com/damontecres/wholphin-extensions" \
    -Dfile="$TARGET_PATH/lib-decoder-${module}-release.aar" \
    -DpomFile="${PROJECT_ROOT}/wholphin-media3/${module}.pom.xml" \
    -DrepositoryId=github
done
