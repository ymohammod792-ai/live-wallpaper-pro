package com.example.live_wallpaper_pro

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import java.net.URL
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
                    "setImageWallpaper" -> {
                        val imageUrl = call.argument<String>("url")
                        val target = call.argument<String>("target") ?: "home"

                        if (imageUrl.isNullOrBlank()) {
                            result.error("NO_URL", "Wallpaper image URL is missing", null)
                        } else {
                            Thread {
                                try {
                                    val connection = URL(imageUrl).openConnection()
                                    connection.connectTimeout = 15000
                                    connection.readTimeout = 20000
                                    connection.getInputStream().use { stream ->
                                        val bitmap = BitmapFactory.decodeStream(stream)
                                            ?: throw Exception("Could not decode wallpaper image")

                                        try {
                                            val manager = WallpaperManager.getInstance(this)
                                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                                                val flags = when (target) {
                                                    "lock" -> WallpaperManager.FLAG_LOCK
                                                    "both" -> WallpaperManager.FLAG_SYSTEM or WallpaperManager.FLAG_LOCK
                                                    else -> WallpaperManager.FLAG_SYSTEM
                                                }
                                                manager.setBitmap(bitmap, null, true, flags)
                                            } else {
                                                if (target != "home") {
                                                    throw Exception("Lock Screen requires Android 7.0 or newer")
                                                }
                                                manager.setBitmap(bitmap)
                                            }
                                        } finally {
                                            bitmap.recycle()
                                        }
                                    }
                                    runOnUiThread { result.success(true) }
                                } catch (e: Exception) {
                                    runOnUiThread {
                                        result.error("IMAGE_WALLPAPER_ERROR", e.message, null)
                                    }
                                }
                            }.start()
                        }
                    }

                    "setImageLiveWallpaper" -> {
                        val imageUrl = call.argument<String>("url")

                        if (imageUrl.isNullOrBlank()) {
                            result.error("NO_URL", "Wallpaper image URL is missing", null)
                        } else {
                            Thread {
                                try {
                                    val connection = URL(imageUrl).openConnection()
                                    connection.connectTimeout = 20000
                                    connection.readTimeout = 30000

                                    val imageFile = java.io.File(filesDir, "image_live_wallpaper_${System.currentTimeMillis()}.img")

                                    connection.getInputStream().use { input ->
                                        java.io.FileOutputStream(imageFile).use { output ->
                                            input.copyTo(output)
                                        }
                                    }

                                    if (!imageFile.exists() || imageFile.length() == 0L) {
                                        throw Exception("Wallpaper image could not be saved")
                                    }

                                    val effectsEnabled = call.argument<Boolean>("effectsEnabled") ?: true
                                    val effectType = call.argument<String>("effectType") ?: "Galaxy"
                                    val effectSpeed = (call.argument<Double>("speed") ?: 1.0).toFloat()
                                        .coerceIn(0.3f, 3.0f)

                                    getSharedPreferences("wallpaper_settings", MODE_PRIVATE)
                                        .edit()
                                        .putString("image_live_path", imageFile.absolutePath)
                                        .putBoolean("image_effect_enabled", effectsEnabled)
                                        .putString("image_effect_type", effectType)
                                        .putFloat("image_effect_speed", effectSpeed)
                                        .apply()

                                    runOnUiThread {
                                        try {
                                            val intent = Intent(
                                                WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER
                                            )
                                            intent.putExtra(
                                                WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                                ComponentName(this, ImageWallpaperService::class.java)
                                            )
                                            startActivity(intent)
                                            result.success(true)
                                        } catch (e: Exception) {
                                            result.error("IMAGE_LIVE_ERROR", e.message, null)
                                        }
                                    }
                                } catch (e: Exception) {
                                    runOnUiThread {
                                        result.error("IMAGE_LIVE_ERROR", e.message, null)
                                    }
                                }
                            }.start()
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
