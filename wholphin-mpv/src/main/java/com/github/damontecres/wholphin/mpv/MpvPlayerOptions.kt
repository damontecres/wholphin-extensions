package com.github.damontecres.wholphin.mpv

import java.io.File

/**
 * Options for configuring [MpvPlayer]
 */
data class MpvPlayerOptions(
    val enableHardwareDecoding: Boolean,
    val useGpuNext: Boolean,
    val tlsCertFile: File?,
)
