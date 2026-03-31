# MPV build scripts

This scripts are adapted from https://github.com/mpv-android/mpv-android/tree/ae0d956c5a98ab8bf25af7e2c73bcb59e19c15b7/buildscripts licensed MIT.

## Instructions

```bash
cd scripts/mpv
./get_dependencies.sh

# Install build dependencies
pip install meson jsonschema

export NDK_PATH=... # Such as ~/Library/Android/sdk/ndk/29.0.14206865
# Build arm64
PATH="$PATH:$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin" ./buildall.sh --clean --arch arm64 mpv
# Build arm32
PATH="$PATH:$NDK_PATH/toolchains/llvm/prebuilt/darwin-x86_64/bin" ./buildall.sh mpv

cd ../../..
env PREFIX32="$(realpath wholphin-mpv/build/libmpv/prefix/armv7l)" PREFIX64="$(realpath wholphin-mpv/build/libmpv/prefix/arm64)" "$NDK_PATH/ndk-build" -C wholphin-mpv/src/main -j && cp -fr wholphin-mpv/src/main/libs/ wholphin-mpv/src/main/jnilibs/
```
