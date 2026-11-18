package com.example.live_wallpaper_pro

import android.media.MediaPlayer
import android.service.wallpaper.WallpaperService
import android.view.SurfaceHolder

class VideoWallpaperService : WallpaperService() {

    override fun onCreateEngine(): Engine {
        return VideoEngine()
    }

    inner class VideoEngine : Engine() {

        private var mediaPlayer: MediaPlayer? = null
        private var isVisible = false
        private var isPrepared = false

        override fun onSurfaceCreated(holder: SurfaceHolder) {
            super.onSurfaceCreated(holder)
            startVideo(holder)
        }

        private fun startVideo(holder: SurfaceHolder) {
            if (mediaPlayer != null || !holder.surface.isValid) return

            val path = getSharedPreferences(
                "wallpaper_settings",
                MODE_PRIVATE
            ).getString("video_path", null) ?: return

            try {
                val player = MediaPlayer()
                mediaPlayer = player

                player.setDataSource(path)
                player.setSurface(holder.surface)
                player.isLooping = true
                player.setVolume(0f, 0f)

                player.setOnPreparedListener {
                    isPrepared = true
                    if (isVisible) it.start()
                }

                player.setOnErrorListener { mp, _, _ ->
                    mp.release()
                    mediaPlayer = null
                    isPrepared = false
                    true
                }

                player.prepareAsync()

            } catch (e: Exception) {
                mediaPlayer?.release()
                mediaPlayer = null
                isPrepared = false
            }
        }

        override fun onVisibilityChanged(visible: Boolean) {
            isVisible = visible

            val player = mediaPlayer

            if (visible) {
                if (player == null) {
                    startVideo(surfaceHolder)
                } else if (isPrepared && !player.isPlaying) {
                    player.start()
                }
            } else {
                if (isPrepared && player?.isPlaying == true) {
                    player.pause()
                }
            }
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder) {
            releasePlayer()
            super.onSurfaceDestroyed(holder)
        }

        private fun releasePlayer() {
            mediaPlayer?.release()
            mediaPlayer = null
            isPrepared = false
        }

        override fun onDestroy() {
            releasePlayer()
            super.onDestroy()
        }
    }
}
