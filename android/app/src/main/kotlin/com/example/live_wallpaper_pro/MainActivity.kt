package com.example.live_wallpaper_pro

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "live_wallpaper_pro/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val path = call.argument<String>("path")
                        if (path.isNullOrBlank()) {
                            result.error("NO_PATH", "Video path is missing", null)
                        } else {
                            try {
                                getSharedPreferences("wallpaper_settings", MODE_PRIVATE).edit().putString("video_path", path).apply()
                                val intent = Intent(
                                    WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER
                                )
                                intent.putExtra(
                                    WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                    ComponentName(
                                        this,
                                        VideoWallpaperService::class.java
                                    )
                                )
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("WALLPAPER_ERROR", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
