# ════════════════════════════════════════════════════════════════
# TURKKALORI - PROGUARD RULES
# ════════════════════════════════════════════════════════════════
#
# ProGuard rules for code optimization and obfuscation
# Applied only in release builds (minifyEnabled true)
#
# ════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────
# FLUTTER
# ────────────────────────────────────────────────────────────────

# Keep Flutter engine classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter embedding
-keep class io.flutter.embedding.** { *; }

# ────────────────────────────────────────────────────────────────
# FIREBASE
# ────────────────────────────────────────────────────────────────

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.android.gms.measurement.** { *; }

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Firebase Messaging (FCM)
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }

# Firebase Performance
-keep class com.google.firebase.perf.** { *; }

# ────────────────────────────────────────────────────────────────
# GSON / JSON SERIALIZATION
# ────────────────────────────────────────────────────────────────

# Keep Gson classes
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep generic signature of Call, Response (R8 full mode strips signatures)
-keepattributes Signature

# Keep custom model classes (replace with your package)
-keep class com.turkkalori.app.models.** { *; }
-keep class com.turkkalori.app.data.** { *; }

# ────────────────────────────────────────────────────────────────
# KOTLIN
# ────────────────────────────────────────────────────────────────

# Keep Kotlin metadata
-keep class kotlin.Metadata { *; }
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Keep Kotlin coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ────────────────────────────────────────────────────────────────
# SUPABASE / POSTGRES
# ────────────────────────────────────────────────────────────────

# Keep Supabase client classes
-keep class io.supabase.** { *; }
-dontwarn io.supabase.**

# ────────────────────────────────────────────────────────────────
# NETWORKING (Dio, Retrofit, OkHttp)
# ────────────────────────────────────────────────────────────────

# OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# Retrofit
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Exceptions

# ────────────────────────────────────────────────────────────────
# IMAGE LOADING (Cached Network Image, etc.)
# ────────────────────────────────────────────────────────────────

# Keep image cache classes
-keep class com.bumptech.glide.** { *; }
-keep public class * implements com.bumptech.glide.module.GlideModule

# ────────────────────────────────────────────────────────────────
# CAMERA & IMAGE PICKER
# ────────────────────────────────────────────────────────────────

# Keep camera plugin classes
-keep class io.flutter.plugins.camera.** { *; }
-keep class io.flutter.plugins.imagepicker.** { *; }

# ────────────────────────────────────────────────────────────────
# HIVE (Local Storage)
# ────────────────────────────────────────────────────────────────

# Keep Hive classes
-keep class io.flutter.plugins.hive.** { *; }
-keep class * extends hive.** { *; }

# ────────────────────────────────────────────────────────────────
# HEALTH KIT / GOOGLE FIT
# ────────────────────────────────────────────────────────────────

# Keep health plugin classes
-keep class app.securestore.** { *; }

# ────────────────────────────────────────────────────────────────
# BARCODE SCANNER
# ────────────────────────────────────────────────────────────────

# Keep ML Kit classes
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }

# ────────────────────────────────────────────────────────────────
# PAYMENT PROVIDERS (Stripe, etc.)
# ────────────────────────────────────────────────────────────────

# Keep Stripe classes
-keep class com.stripe.** { *; }

# ────────────────────────────────────────────────────────────────
# GENERAL OPTIMIZATIONS
# ────────────────────────────────────────────────────────────────

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep annotations
-keepattributes *Annotation*

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom views
-keep public class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
    public void set*(...);
}

# Keep Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ────────────────────────────────────────────────────────────────
# CRASH REPORTING
# ────────────────────────────────────────────────────────────────

# Keep line numbers for crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ────────────────────────────────────────────────────────────────
# WARNINGS TO IGNORE
# ────────────────────────────────────────────────────────────────

-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# ════════════════════════════════════════════════════════════════
# END OF PROGUARD RULES
# ════════════════════════════════════════════════════════════════
