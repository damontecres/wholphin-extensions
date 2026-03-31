# Wholphin Extensions

This repository builds and publishes various playback extension modules for [Wholphin](https://github.com/damontecres/Wholphin), an Android TV client for Jellyfin.

These modules use native code and are built outside of gradle, but published as Android libraries. This allows for Wholphin developers to use them without needing to build the extensions locally.

## Usage

GitHub does not allow anonymous read for its maven package registry, so you must add credentials.

1. [Create a GitHub personal access token (classic)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token-classic) with `packages:read` permissions
    - It must be _classic_ token
2. Add your username & token to `~/.gradle/gradle.properties`:
```
WholphinExtensionsUsername=<github username>
WholphinExtensionsPassword=<github token>
```

## Components

### wholphin-media3

Builds the decoder extension modules for `ExoPlayer` which supports extra codecs during playback.

### wholphin-mpv

Builds `libmpv` for use as an alternative playback engine.

This does not include any of the Kotlin code.
