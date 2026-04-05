package com.example.student_academic_assistant

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "study_app/dnd").setMethodCallHandler { call, result ->
			when (call.method) {
				"setDnd" -> {
					val enabled = call.argument<Boolean>("enabled") ?: false
					val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
					if (!nm.isNotificationPolicyAccessGranted) {
						result.error("NO_PERMISSION", "Notification policy access not granted", null)
						return@setMethodCallHandler
					}
					val filter = if (enabled) NotificationManager.INTERRUPTION_FILTER_NONE else NotificationManager.INTERRUPTION_FILTER_ALL
					nm.setInterruptionFilter(filter)
					result.success(true)
				}
				"openDndSettings" -> {
					val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS)
					intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
					startActivity(intent)
					result.success(true)
				}
				"hasDndPermission" -> {
					val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
					result.success(nm.isNotificationPolicyAccessGranted)
				}
				else -> result.notImplemented()
			}
		}
	}
}
