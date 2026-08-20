package com.example.musicbye

import android.Manifest
import android.content.ContentUris
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.musicbye/library"
    private val permissionRequestCode = 1001
    private var pendingPermissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestAudioPermission" -> requestAudioPermission(result)
                "getSongs" -> getSongs(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun hasAudioPermission(): Boolean {
        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

        return ContextCompat.checkSelfPermission(
            this,
            permission,
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestAudioPermission(result: MethodChannel.Result) {
        if (hasAudioPermission()) {
            result.success(true)
            return
        }

        val permission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            Manifest.permission.READ_MEDIA_AUDIO
        } else {
            Manifest.permission.READ_EXTERNAL_STORAGE
        }

        pendingPermissionResult = result
        requestPermissions(arrayOf(permission), permissionRequestCode)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == permissionRequestCode) {
            pendingPermissionResult?.success(hasAudioPermission())
            pendingPermissionResult = null
        }
    }

    private fun getSongs(result: MethodChannel.Result) {
        if (!hasAudioPermission()) {
            result.error("PERMISSION_DENIED", "No hay permiso para leer audio.", null)
            return
        }

        val songs = mutableListOf<Map<String, Any>>()

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.DURATION,
        )

        val selection =
            "${MediaStore.Audio.Media.IS_MUSIC} != 0 AND " +
            "${MediaStore.Audio.Media.DURATION} > 10000"

        contentResolver.query(
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            null,
            "${MediaStore.Audio.Media.TITLE} COLLATE NOCASE ASC",
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)

                songs.add(
                    mapOf(
                        "id" to id,
                        "title" to (cursor.getString(titleColumn) ?: "Sin título"),
                        "artist" to (cursor.getString(artistColumn) ?: "Artista desconocido"),
                        "album" to (cursor.getString(albumColumn) ?: "Álbum desconocido"),
                        "duration" to cursor.getLong(durationColumn),
                        "uri" to ContentUris.withAppendedId(
                            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                            id,
                        ).toString(),
                    ),
                )
            }
        }

        result.success(songs)
    }
}