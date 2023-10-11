package com.cube.magicstep

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.telephony.PhoneNumberUtils
import androidx.annotation.NonNull
import com.cube.magicstep.R
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "native.magicstep.dev/share"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            if (call.method == "shareToWhatsapp") {
                val filePath = call.argument<String>("filePath");
                val subject = call.argument<String>("subject");
                val text = call.argument<String>("text");
                val shareText = call.argument<String>("shareText");
                if (filePath.isNullOrEmpty() || subject.isNullOrEmpty() || text.isNullOrEmpty() || shareText.isNullOrEmpty()) {
                    result.error("one or more argument is null", "arguments cannot be null", null)
                }
                sharePdfToWhatsapp(filePath!!, subject!!, text!!, shareText!!);
                result.success(null);

            } else {
                result.notImplemented()
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val soundUri = Uri.parse("android.resource://" + applicationContext.packageName + "/" + R.raw.ring_ring)
            val audioAttributes = AudioAttributes.Builder()
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .setUsage(AudioAttributes.USAGE_ALARM)
                .build()
            val notificationChannel = NotificationChannel("your_channel_id", "your_channel_name", NotificationManager.IMPORTANCE_HIGH)
            notificationChannel.setSound(soundUri, audioAttributes)
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(notificationChannel)
        }
    }

    private fun sharePdfToWhatsapp(
        filePath: String,
        subject: String,
        text: String,
        shareText: String
    ) {
        val sendIntent = Intent("android.intent.action.SEND")
        val f = File(filePath)
        val uri = Uri.fromFile(f)
        sendIntent.component = ComponentName("com.whatsapp", "com.whatsapp.ContactPicker")
        sendIntent.type = "application/pdf"
        sendIntent.putExtra(Intent.EXTRA_STREAM, uri)
        sendIntent.putExtra(
            "jid",
            PhoneNumberUtils.stripSeparators("7738226424").toString() + "@s.whatsapp.net"
        )
        sendIntent.putExtra(Intent.EXTRA_TEXT, "Sample text")
        startActivity(sendIntent)
    }
}