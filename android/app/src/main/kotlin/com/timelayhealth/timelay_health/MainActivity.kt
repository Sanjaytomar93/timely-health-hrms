package com.timelayhealth.timelay_health

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private val downloadsChannel = "com.timelayhealth.timelay_health/downloads"
    private val channelId = "default"
    private val reqPostNotifications = 9101

    private var pendingResult: MethodChannel.Result? = null
    private var pendingFileName: String? = null
    private var pendingBytes: ByteArray? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ensureNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, downloadsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "savePdfAndNotify" -> {
                        val fileName = call.argument<String>("fileName").orEmpty()
                        val bytes = call.argument<ByteArray>("bytes")
                        if (fileName.isEmpty() || bytes == null || bytes.isEmpty()) {
                            result.error("invalid_args", "fileName/bytes required", null)
                            return@setMethodCallHandler
                        }
                        saveThenNotify(fileName, bytes, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != reqPostNotifications) return

        val fileName = pendingFileName
        val bytes = pendingBytes
        val result = pendingResult
        pendingFileName = null
        pendingBytes = null
        pendingResult = null

        if (fileName.isNullOrEmpty() || bytes == null) {
            result?.error("cancelled", "Download cancelled", null)
            return
        }

        val granted = grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED
        try {
            val path = savePdf(fileName, bytes)
            if (granted) showDownloadNotification(fileName, path)
            result?.success(
                mapOf(
                    "path" to path,
                    "notified" to granted,
                ),
            )
        } catch (e: Exception) {
            result?.error("save_failed", e.message, null)
        }
    }

    private fun saveThenNotify(
        fileName: String,
        bytes: ByteArray,
        result: MethodChannel.Result,
    ) {
        if (Build.VERSION.SDK_INT >= 33 &&
            ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.POST_NOTIFICATIONS,
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            pendingFileName = fileName
            pendingBytes = bytes
            pendingResult = result
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                reqPostNotifications,
            )
            return
        }

        try {
            val path = savePdf(fileName, bytes)
            showDownloadNotification(fileName, path)
            result.success(
                mapOf(
                    "path" to path,
                    "notified" to true,
                ),
            )
        } catch (e: Exception) {
            result.error("save_failed", e.message, null)
        }
    }

    private fun savePdf(fileName: String, bytes: ByteArray): String {
        val dir = getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS) ?: filesDir
        if (!dir.exists()) dir.mkdirs()
        val file = File(dir, fileName)
        FileOutputStream(file).use { it.write(bytes) }
        return file.absolutePath
    }

    private fun ensureNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val channel = NotificationChannel(
            channelId,
            "Timely notifications",
            NotificationManager.IMPORTANCE_HIGH,
        )
        channel.enableVibration(true)
        channel.setShowBadge(true)
        manager.createNotificationChannel(channel)
    }

    private fun showDownloadNotification(fileName: String, filePath: String) {
        ensureNotificationChannel()
        val manager = getSystemService(NotificationManager::class.java) ?: return
        val file = File(filePath)
        val uri: Uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )
        val viewIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(uri, "application/pdf")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        val pending = PendingIntent.getActivity(
            this,
            fileName.hashCode(),
            viewIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        builder
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Download complete")
            .setContentText(fileName)
            .setStyle(Notification.BigTextStyle().bigText("Downloaded $fileName"))
            .setAutoCancel(true)
            .setContentIntent(pending)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            @Suppress("DEPRECATION")
            builder.setPriority(Notification.PRIORITY_HIGH)
        }
        manager.notify((System.currentTimeMillis() % Int.MAX_VALUE).toInt(), builder.build())
    }
}
