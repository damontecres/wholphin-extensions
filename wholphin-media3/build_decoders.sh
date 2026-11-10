#!/usr/bin/env bash
set -ex

if [ -z "$1" ]; then
  echo "Error: Must provide NDK path"
  exit 1
fi
NDK_PATH="$1"

SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "${SCRIPT_PATH}")"
PROJECT_ROOT="$(realpath "${SCRIPT_DIR}/../")"

# Config
ANDROID_ABI=21
MODULES=(ffmpeg av1 flac opus)
ENABLED_DECODERS=(dca ac3 eac3 mlp truehd alac pcm_mulaw pcm_alaw mp3)
FFMPEG_BRANCH="n9.0"
DAV1D_BRANCH="1.5.4"
FLAC_BRANCH="master"
OPUS_BRANCH="main"

# Path configs
DIR_PATH="$(pwd)"
TARGET_PATH="$PROJECT_ROOT/wholphin-media3/libs"
MEDIA_PATH="$DIR_PATH/ffmpeg_decoder/media"
FFMPEG_MODULE_PATH="$MEDIA_PATH/libraries/decoder_ffmpeg/src/main"
FFMPEG_PATH="$DIR_PATH/ffmpeg_decoder/ffmpeg"
AV1_MODULE_PATH="$MEDIA_PATH/libraries/decoder_av1/src/main"
FLAC_MODULE_PATH="$MEDIA_PATH/libraries/decoder_flac/src/main"
OPUS_MODULE_PATH="$MEDIA_PATH/libraries/decoder_opus/src/main"
HOST="$(uname -s | tr '[:upper:]' '[:lower:]')"
HOST_PLATFORM="$HOST-x86_64"

if [[ "$2" == "--clean" ]]; then
  rm -rf ffmpeg_decoder
  rm -f "$TARGET_PATH/lib-decoder-ffmpeg-release.aar"
  rm -f "$TARGET_PATH/lib-decoder-av1-release.aar"
fi

mkdir -p "$TARGET_PATH"
mkdir -p ffmpeg_decoder

echo "$PROJECT_ROOT/gradle/libs.versions.toml"

media_version="$(grep "androidx-media3 = " "$PROJECT_ROOT/gradle/libs.versions.toml" | awk -F'"' '{print $2}')"

pushd ffmpeg_decoder || exit

if [[ -d media ]]; then
  pushd media || exit
  git fetch origin "$media_version" --depth 1
  git checkout --force FETCH_HEAD
  popd
else
  git clone https://github.com/androidx/media.git --depth 1 --single-branch -b "$media_version" media
fi

if [[ -d ffmpeg ]]; then
  pushd ffmpeg || exit
  git fetch origin "$FFMPEG_BRANCH" --depth 1
  git checkout --force FETCH_HEAD
  popd
else
  git clone https://github.com/FFmpeg/FFmpeg --depth 1 --single-branch -b "$FFMPEG_BRANCH" ffmpeg
fi

# Patch media3's ffmpeg build script to remove old flag
sed -i '/--disable-postproc/d' media/libraries/decoder_ffmpeg/src/main/jni/build_ffmpeg.sh

[[ ! -d "${FFMPEG_MODULE_PATH}/jni/ffmpeg" ]] && ln -s "$FFMPEG_PATH" "${FFMPEG_MODULE_PATH}/jni/ffmpeg"

pushd "${FFMPEG_MODULE_PATH}/jni" || exit

./build_ffmpeg.sh "${FFMPEG_MODULE_PATH}" "${NDK_PATH}" "${HOST_PLATFORM}" "${ANDROID_ABI}" "${ENABLED_DECODERS[@]}"

# av1 module

pushd "$AV1_MODULE_PATH/jni" || exit

if [[ ! -d cpu_features ]]; then
  git clone https://github.com/google/cpu_features --depth 1 --single-branch cpu_features
fi

pushd "$AV1_MODULE_PATH/jni" || exit

if [[ -d dav1d ]]; then
  pushd dav1d || exit
  git fetch origin "$DAV1D_BRANCH" --depth 1
  git checkout --force FETCH_HEAD
else
  git clone https://code.videolan.org/videolan/dav1d --depth 1 --single-branch -b "$DAV1D_BRANCH" dav1d
fi

pushd "$AV1_MODULE_PATH/jni" || exit

/usr/bin/env bash ./build_dav1d.sh "${AV1_MODULE_PATH}" "${NDK_PATH}" "${HOST_PLATFORM}"

# flac module

pushd "$FLAC_MODULE_PATH/jni" || exit

if [[ -d libflac ]]; then
  pushd libflac || exit
  git fetch origin "$FLAC_BRANCH" --depth 1
  git checkout --force FETCH_HEAD
else
  git clone https://github.com/xiph/flac.git --depth 1 --single-branch -b "$FLAC_BRANCH" libflac
fi

# opus module

pushd "$OPUS_MODULE_PATH/jni" || exit

if [[ -d libopus ]]; then
  pushd libopus || exit
  git fetch origin "$OPUS_BRANCH" --depth 1
  git checkout --force FETCH_HEAD
else
  git clone https://github.com/xiph/opus.git --depth 1 --single-branch -b "$OPUS_BRANCH" libopus
fi

# Assemble aar files

pushd "$MEDIA_PATH" || exit
pre=("${MODULES[@]/#/:lib-decoder-}")
args=("${pre[@]/%/:assemble}")
echo "${args[@]}"
./gradlew "${args[@]}"
popd || exit

for module in "${MODULES[@]}"; do
  cp "$MEDIA_PATH/libraries/decoder_$module/buildout/outputs/aar/lib-decoder-$module-release.aar" "$TARGET_PATH/"
done
popd || exit
