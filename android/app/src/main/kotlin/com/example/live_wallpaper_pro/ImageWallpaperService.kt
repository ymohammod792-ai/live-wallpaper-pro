package com.example.live_wallpaper_pro

import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.os.Handler
import android.os.Looper
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder
import kotlin.random.Random

class ImageWallpaperService : WallpaperService() {

    private data class Particle(
        var x: Float,
        var y: Float,
        var size: Float,
        var speed: Float
    )

    override fun onCreateEngine(): Engine = ImageEngine()

    inner class ImageEngine : Engine() {
        private val handler = Handler(Looper.getMainLooper())
        private var bitmap: Bitmap? = null
        private var visible = false
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.FILTER_BITMAP_FLAG)
        private val particles = mutableListOf<Particle>()
        private var frameWidth = 0
        private var frameHeight = 0


        private val frameRunnable = object : Runnable {
            override fun run() {
                if (visible) {
                    drawFrame()
                    handler.postDelayed(this, 33L)
                }
            }
        }

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            loadWallpaper()
            startAnimation()
        }

        override fun onSurfaceChanged(
            holder: SurfaceHolder,
            format: Int,
            width: Int,
            height: Int
        ) {
            super.onSurfaceChanged(holder, format, width, height)
            frameWidth = width
            frameHeight = height
            resetParticles()
            drawFrame()
        }

        override fun onVisibilityChanged(isVisible: Boolean) {
            visible = isVisible
            if (visible) startAnimation() else stopAnimation()
        }

        private fun loadWallpaper() {
            val path = getSharedPreferences(
                "wallpaper_settings", MODE_PRIVATE
            ).getString("image_live_path", null)

            bitmap?.recycle()
            bitmap = if (path.isNullOrBlank()) null else BitmapFactory.decodeFile(path)
        }

        private fun startAnimation() {
            handler.removeCallbacks(frameRunnable)
            if (visible) handler.post(frameRunnable)
        }

        private fun stopAnimation() {
            handler.removeCallbacks(frameRunnable)
        }

        private fun resetParticles() {
            particles.clear()
            repeat(100) {
                particles.add(
                    Particle(
                        Random.nextFloat() * frameWidth.coerceAtLeast(1),
                        Random.nextFloat() * frameHeight.coerceAtLeast(1),
                        Random.nextFloat() * 3f + 1f,
                        Random.nextFloat() * 3f + 1f
                    )
                )
            }
        }

        private fun drawFrame() {
            val holder = surfaceHolder
            var canvas: Canvas? = null

            try {
                canvas = holder.lockCanvas()
                if (canvas != null) {
                    val image = bitmap
                    if (image != null && !image.isRecycled) {
                        val scale = maxOf(
                            canvas.width.toFloat() / image.width,
                            canvas.height.toFloat() / image.height
                        )
                        val width = image.width * scale
                        val height = image.height * scale
                        val left = (canvas.width - width) / 2f
                        val top = (canvas.height - height) / 2f

                        paint.alpha = 255
                        canvas.drawBitmap(
                            image,
                            null,
                            RectF(left, top, left + width, top + height),
                            paint
                        )
                    } else {
                        canvas.drawColor(Color.BLACK)
                    }

                    drawEffect(canvas)
                }
            } catch (_: Exception) {
            } finally {
                if (canvas != null) {
                    try {
                        holder.unlockCanvasAndPost(canvas)
                    } catch (_: Exception) {
                    }
                }
            }
        }

        private fun drawEffect(canvas: Canvas) {
            val prefs = getSharedPreferences("wallpaper_settings", MODE_PRIVATE)
            if (!prefs.getBoolean("image_effect_enabled", true)) return

            val type = prefs.getString("image_effect_type", "Galaxy") ?: "Galaxy"
            val speed = prefs.getFloat("image_effect_speed", 1f).coerceIn(0.3f, 3f)

            for (p in particles) {
                when (type) {
                    "Rain" -> {
                        paint.color = Color.argb(170, 170, 210, 255)
                        paint.strokeWidth = 2f
                        canvas.drawLine(p.x, p.y, p.x - 5f, p.y + 18f, paint)
                        p.y += (12f * speed * p.speed)
                    }
                    "Snow" -> {
                        paint.color = Color.argb(220, 255, 255, 255)
                        canvas.drawCircle(p.x, p.y, p.size + 1f, paint)
                        p.y += (2f * speed * p.speed)
                        p.x += kotlin.math.sin(p.y / 25f) * speed
                    }
                    "Particles" -> {
                        paint.color = Color.argb(190, 220, 190, 255)
                        canvas.drawCircle(p.x, p.y, p.size + 1f, paint)
                        p.y -= (2f * speed * p.speed)
                    }
                    else -> {
                        paint.color = Color.argb(210, 210, 220, 255)
                        canvas.drawCircle(p.x, p.y, p.size, paint)
                        p.y -= (0.7f * speed * p.speed)
                    }
                }

                if (p.y > canvas.height + 20f || p.y < -20f) {
                    p.y = if (type == "Rain" || type == "Snow") -10f
                    else canvas.height + 10f
                    p.x = Random.nextFloat() * canvas.width
                }
                if (p.x < 0f) p.x = canvas.width.toFloat()
                if (p.x > canvas.width) p.x = 0f
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            stopAnimation()
            super.onSurfaceDestroyed(holder)
        }

        override fun onDestroy() {
            stopAnimation()
            bitmap?.recycle()
            bitmap = null
            super.onDestroy()
        }
    }
}
