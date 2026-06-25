@file:Suppress("ktlint:standard:function-naming")

package com.github.damontecres.wholphin.mpv.testapp

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.focusable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.RectangleShape
import androidx.compose.ui.input.key.onKeyEvent
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.media3.common.MediaItem
import androidx.media3.common.PlaybackException
import androidx.media3.common.Player
import androidx.media3.common.util.UnstableApi
import androidx.media3.ui.compose.PlayerSurface
import androidx.media3.ui.compose.SURFACE_TYPE_SURFACE_VIEW
import androidx.media3.ui.compose.modifiers.resizeWithContentScale
import androidx.media3.ui.compose.state.rememberPlayPauseButtonState
import androidx.media3.ui.compose.state.rememberPresentationState
import androidx.tv.material3.Button
import androidx.tv.material3.ExperimentalTvMaterial3Api
import androidx.tv.material3.MaterialTheme
import androidx.tv.material3.Surface
import androidx.tv.material3.Text
import androidx.tv.material3.surfaceColorAtElevation
import com.github.damontecres.wholphin.mpv.MpvPlayer
import com.github.damontecres.wholphin.mpv.testapp.ui.theme.WholphinextensionsTheme
import kotlinx.coroutines.delay
import timber.log.Timber

class MainActivity : ComponentActivity() {
    @OptIn(ExperimentalTvMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Timber.plant(Timber.DebugTree())
        setContent {
            WholphinextensionsTheme(true) {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    shape = RectangleShape,
                ) {
                    var input by remember { mutableStateOf("") }
                    var submit by remember { mutableStateOf(false) }
                    if (submit) {
                        val urls = remember(input) { input.lines() }
                        Playback(urls, Modifier.fillMaxSize())
                    } else {
                        InputUrls(
                            text = input,
                            onTextChange = { input = it },
                            onSubmit = { submit = true },
                            modifier = Modifier.fillMaxSize(),
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun InputUrls(
    text: String,
    onTextChange: (String) -> Unit,
    onSubmit: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(modifier = modifier.padding(16.dp)) {
        BasicTextField(
            value = text,
            onValueChange = onTextChange,
            textStyle = MaterialTheme.typography.bodyLarge.copy(color = MaterialTheme.colorScheme.onSurface),
            maxLines = 4,
            modifier =
                Modifier
                    .size(400.dp, 300.dp)
                    .background(MaterialTheme.colorScheme.surfaceColorAtElevation(1.dp)),
        )
        Button(onSubmit) {
            Text("Submit")
        }
    }
}

@androidx.annotation.OptIn(UnstableApi::class)
@Composable
fun Playback(
    urls: List<String>,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current
    val player = remember { MpvPlayer(context, false, false) }
    val presentationState = rememberPresentationState(player, false)
    var playerSize by remember { mutableFloatStateOf(1f) }
    val focusRequester = remember { FocusRequester() }
    LaunchedEffect(Unit) {
        focusRequester.requestFocus()
        player.addListener(
            object : Player.Listener {
                override fun onPlayerError(error: PlaybackException) {
                    Timber.e(error)
                    Toast.makeText(context, "Error: ${error.localizedMessage}", Toast.LENGTH_LONG).show()
                }
            },
        )
        val mediaItems =
            urls.map {
                MediaItem
                    .Builder()
                    .setUri(it)
                    .setMediaId(it)
                    .build()
            }
        player.setMediaItems(mediaItems, 0, 0)
        player.play()
    }
    val playPauseState = rememberPlayPauseButtonState(player)
    Box(
        modifier = modifier.fillMaxSize(),
    ) {
        val scaledModifier =
            Modifier.resizeWithContentScale(ContentScale.Fit, presentationState.videoSizeDp)
        PlayerSurface(
            player = player,
            surfaceType = SURFACE_TYPE_SURFACE_VIEW,
            modifier = scaledModifier.fillMaxSize(playerSize),
        )
        if (presentationState.coverSurface) {
            Box(
                contentAlignment = Alignment.Center,
                modifier =
                    Modifier
                        .matchParentSize()
                        .background(Color.Black),
            ) {
                Text(text = "Cover Surface", color = Color.White)
            }
        }
        Row(
            modifier = Modifier.align(Alignment.BottomCenter),
        ) {
            Button(
                onClick = playPauseState::onClick,
                enabled = playPauseState.isEnabled,
                modifier = Modifier.focusRequester(focusRequester),
            ) {
                val text = if (playPauseState.showPlay) "Play" else "Pause"
                Text(text)
            }
        }
    }
}
