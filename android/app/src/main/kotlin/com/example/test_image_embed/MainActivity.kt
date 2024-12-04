package com.example.test_image_embed

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {

    companion object {
        const val DEFAULT_CHANNEL_ID = "test_image_embed_notifications"
        const val CHANNEL = "com.example.test_image_embed/channel"
    }

    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Create a MethodChannel and set a method call handler
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        // Set up the method call handler
        channel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "compareImages" -> {
                    // Use the correct argument names based on what Flutter is sending
                    val imagePath1 = call.argument<String>("imageOnePath")
                    val imagePath2 = call.argument<String>("imageTwoPath")

                    if (imagePath1 != null && imagePath2 != null) {
                        val similarityScore = compareImages(imagePath1, imagePath2)
                        result.success(mapOf("similarity" to similarityScore, "inferenceTime" to 100))  // Example response
                    } else {
                        result.error("INVALID_ARGUMENTS", "Image paths are required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Create the default notification channel for the app
        createNotificationChannel(
            DEFAULT_CHANNEL_ID,
            "Image Embed Notifications",
            "Notifications for image embed feature"
        )

        // Handle intent if the activity was opened via notification
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Handle new intent when activity is already running
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        // Handle incoming intents (e.g., notification clicks)
        val imageId = intent.getStringExtra("imageId")
        if (imageId != null) {
            Log.d("MainActivity", "Passing imageId to Flutter: $imageId")
            channel?.invokeMethod("openImage", imageId)
        } else {
            Log.d("MainActivity", "No imageId found in the intent")
        }
    }

    // Function to create a notification channel (only needed on Android 8.0+)
    private fun createNotificationChannel(channelId: String, channelName: String, channelDescription: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = channelDescription
            }
            val notificationManager: NotificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    // Function to compare images (stub for your image comparison logic)
    private fun compareImages(imagePath1: String, imagePath2: String): Float {
        // Load the images from the file paths
        val image1 = File(imagePath1).let { BitmapFactory.decodeFile(it.absolutePath) }
        val image2 = File(imagePath2).let { BitmapFactory.decodeFile(it.absolutePath) }

        Log.d("MainActivity", "Image 1 path: $imagePath1")
        Log.d("MainActivity", "Image 2 path: $imagePath2")


        // Here, you can implement your actual image comparison logic
        // For now, let's return a placeholder similarity score (between 0 and 1)
        if (image1 != null && image2 != null) {
            // Placeholder similarity logic (replace with actual image comparison)
            val similarity = 0.95f // Example similarity score
            Log.d("MainActivity", "Image similarity score: $similarity")
            return similarity
        } else {
            Log.e("MainActivity", "One or both images failed to load")
            return 0f  // Return a similarity score of 0 if images cannot be compared
        }
    }
}
