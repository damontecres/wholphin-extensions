#!/usr/bin/env bash

set -exou pipefail

v_lua=5.2.4
v_unibreak=8.0
v_harfbuzz=15.0.0
v_fribidi=1.0.17
v_freetype=VER-2-15-0
v_mbedtls=3.6.7
v_libxml2=2.15.4
v_fontconfig=2.18.3
v_curl=8.23.0
v_dav1d=1.5.4
v_libass=0.17.5
v_libplacebo=7.387.0
v_ffmpeg=n9.0
v_mpv=0.42.0

SCRIPT_PATH="$( dirname "${BASH_SOURCE[0]}" )"
DEPS_PATH="../../$SCRIPT_PATH/build/libmpv/deps"
mkdir -p "$DEPS_PATH"
DEPS_PATH="$(realpath ../../$SCRIPT_PATH/build/libmpv/deps)"

pushd "$DEPS_PATH" || exit

function clone(){
  repo=$1
  branch=$2
  dir=$3
  shift 3

  if [[ -d "$dir" ]]; then
    pushd "$dir" || exit
		git fetch origin "$branch"
    git checkout --force "$branch"
    popd || exit
  else
    git clone "$repo" --depth 1 --single-branch -b "$branch" "$dir" "$@"
  fi
}

clone "https://github.com/videolan/dav1d" "${v_dav1d}" dav1d

clone "https://github.com/FFmpeg/FFmpeg" "${v_ffmpeg}" ffmpeg

clone "https://gitlab.freedesktop.org/freetype/freetype.git" "${v_freetype}" freetype2 --recurse-submodules

clone "https://github.com/libass/libass" "${v_libass}" libass

clone "https://github.com/haasn/libplacebo" "v${v_libplacebo}" libplacebo --recurse-submodules

clone "https://github.com/mpv-player/mpv" "v${v_mpv}" mpv


if [[ ! -d mbedtls ]]; then
	mkdir mbedtls
	wget https://github.com/Mbed-TLS/mbedtls/releases/download/mbedtls-${v_mbedtls}/mbedtls-${v_mbedtls}.tar.bz2 -O - | \
		tar -xj -C mbedtls --strip-components=1
fi

if [[ ! -d fribidi ]]; then
	mkdir fribidi
	wget https://github.com/fribidi/fribidi/releases/download/v${v_fribidi}/fribidi-${v_fribidi}.tar.xz -O - | \
		tar -xJ -C fribidi --strip-components=1
fi

if [[ ! -d harfbuzz ]]; then
	mkdir harfbuzz
	wget https://github.com/harfbuzz/harfbuzz/releases/download/${v_harfbuzz}/harfbuzz-${v_harfbuzz}.tar.xz -O - | \
		tar -xJ -C harfbuzz --strip-components=1
fi

if [[ ! -d unibreak ]]; then
	mkdir unibreak
	wget https://github.com/adah1972/libunibreak/releases/download/libunibreak_${v_unibreak//./_}/libunibreak-${v_unibreak}.tar.gz -O - | \
		tar -xz -C unibreak --strip-components=1
fi

if [[ ! -d lua ]]; then
	mkdir lua
	wget https://www.lua.org/ftp/lua-${v_lua}.tar.gz -O - | \
		tar -xz -C lua --strip-components=1
fi

if [ ! -d libxml2 ]; then
	mkdir libxml2
	wget https://gitlab.gnome.org/GNOME/libxml2/-/archive/v${v_libxml2}/libxml2-v${v_libxml2}.tar.gz -O - | \
		tar -xz -C libxml2 --strip-components=1
fi

if [ ! -d fontconfig ]; then
	mkdir fontconfig
	wget https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/${v_fontconfig}/fontconfig-${v_fontconfig}.tar.gz -O - | \
		tar -xz -C fontconfig --strip-components=1
fi

if [ ! -d curl ]; then
	mkdir curl
	wget https://curl.se/download/curl-$v_curl.tar.gz -O - | \
		tar -xz -C curl --strip-components=1
fi

# python packages: jsonschema jinja2 meson

popd || exit
