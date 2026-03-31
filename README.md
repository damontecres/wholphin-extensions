# Wholphin Extensions

This repository builds and publishes various playback extension modules for [Wholphin](https://github.com/damontecres/Wholphin), an Android TV client for Jellyfin.

These modules use native code and are built outside of gradle, but published as Android libraries. This allows for Wholphin developers to use them without needing to build the extensions locally.

## wholphin-media3

Builds the decoder extension modules for `ExoPlayer` which supports extra codecs during playback.

## wholphin-mpv

Builds `libmpv` for use as an alternative playback engine.

This does not include any of the Kotlin code.
