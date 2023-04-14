package com.cube.magicstep

import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.telephony.PhoneNumberUtils
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "native.magicstep.dev/share"


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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
//        if (file.exists()) {
//            val uri =
//                if (Build.VERSION.SDK_INT < 24) Uri.fromFile(file) else Uri.parse(file.path)
//            val shareIntent = Intent().apply {
//                action = Intent.ACTION_SEND
//                type = "application/pdf"
//                putExtra(Intent.EXTRA_STREAM, uri)
//                putExtra(Intent.EXTRA_SUBJECT, subject)
//                putExtra(Intent.EXTRA_TEXT, text)
//
//            }
//            shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
//            startActivity(Intent.createChooser(shareIntent, shareText))
//        }
    }
}
