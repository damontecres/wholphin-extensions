# Wholphin Extensions

This repository builds and publishes various playback extension modules for [Wholphin](https://github.com/damontecres/Wholphin), an Android TV client for Jellyfin.

These modules use native code and are built outside of gradle, but published as Android libraries. This allows for Wholphin developers to use them without needing to build the extensions locally.

## Usage

### Pre-built binaries

When building Wholphin, if you want to use the pre-built binaries from this repository's CI, you just need to add GitHub credentials to Gradle to pull the [artifacts](https://github.com/damontecres?tab=packages&repo_name=wholphin-extensions).

Note: GitHub does not allow anonymous read for its maven package registry, so you must add credentials!

1. [Create a GitHub personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) with `packages:read` permissions
    - It must be _classic_ token
2. Add your username & token to your global Gradle properties (e.g. `~/.gradle/gradle.properties`):
```
WholphinExtensionsUsername=<github username>
WholphinExtensionsPassword=<github token>
```

### Build from source

When building Wholphin, the build script will prefer locally built artifacts from this repo.

1. [Build the media3 decoders](./wholphin-media3/README.md)
2. [Build libmpv](./wholphin-mpv/README.md)
3. Build the AARs with `./gradlew assembleRelease`
4. Copy the `.aar` files to `/path/to/wholphin/repo/app/libs/`
5. Build Wholphin as normal

## Components

### wholphin-media3

Builds the decoder extension modules for `ExoPlayer` which supports extra codecs during playback.

### wholphin-mpv

Builds `libmpv` for use as an alternative playback engine.

Includes a `androidx.media3.common.Player` implementation that handles most functionality.
