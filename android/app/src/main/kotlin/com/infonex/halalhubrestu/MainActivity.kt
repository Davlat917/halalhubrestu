package com.infonex.halalhubrestu

import android.media.AudioAttributes
import android.media.AudioManager
import android.media.MediaPlayer
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var orderAlertPlayer: MediaPlayer? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.infonex.halalhubrestu/vendor_order_alert",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLoop" -> {
                    try {
                        stopOrderAlertLoopInternal()
                        val mp = MediaPlayer()
                        resources.openRawResourceFd(R.raw.new_order).use { afd ->
                            mp.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
                        }
                        mp.isLooping = true
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            // USAGE_ALARM: emulyator va “media 0” holatlarida ham eshitilish ehtimoli yuqori.
                            mp.setAudioAttributes(
                                AudioAttributes.Builder()
                                    .setUsage(AudioAttributes.USAGE_ALARM)
                                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                                    .build(),
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            mp.setAudioStreamType(AudioManager.STREAM_ALARM)
                        }
                        mp.setVolume(1f, 1f)
                        mp.prepare()
                        mp.start()
                        orderAlertPlayer = mp
                        result.success(null)
                    } catch (e: Exception) {
                        stopOrderAlertLoopInternal()
                        result.error("START", e.message, null)
                    }
                }
                "stopLoop" -> {
                    stopOrderAlertLoopInternal()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun stopOrderAlertLoopInternal() {
        orderAlertPlayer?.let { p ->
            try {
                if (p.isPlaying) p.stop()
            } catch (_: Exception) {
            }
            try {
                p.release()
            } catch (_: Exception) {
            }
        }
        orderAlertPlayer = null
    }

    override fun onDestroy() {
        stopOrderAlertLoopInternal()
        super.onDestroy()
    }
}
