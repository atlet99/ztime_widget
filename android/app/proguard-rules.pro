# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Wakelock Plus
-keep class com.fluttercampus.wakelock.** { *; }

# Home Widget
-keep class es.antonborri.home_widget.** { *; }

# WorkManager
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.ListenableWorker { *; }

# Widget Provider
-keep class com.gosayram.ztime_widget.CustomClockWidgetProvider { *; }

# Play Core (Flutter embedding references, safe to ignore for non-split APKs)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Keep annotations
-keepattributes *Annotation*
