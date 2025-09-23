# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Google Maps
-keep class com.google.android.gms.maps.** { *; }

# QR Code Scanner
-keep class net.sourceforge.zbar.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Location
-keep class com.lyokone.location.** { *; }

# Local Notifications
-keep class com.dexterous.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Package Info
-keep class io.flutter.plugins.packageinfo.** { *; }

# Don't warn about missing classes
-dontwarn com.google.**
-dontwarn io.flutter.**
-dontwarn javax.annotation.**
-dontwarn kotlin.**