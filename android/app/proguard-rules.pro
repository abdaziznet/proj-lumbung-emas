# ============================================
# ProGuard/R8 Obfuscation Rules for LumbungEmas
# Protects business logic from reverse engineering
# ============================================

# ============================================
# Framework & Core Libraries (Keep, Don't Obfuscate)
# ============================================

# Flutter & Dart Framework
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Google Play Services & Firebase
-keep class com.google.** { *; }
-keep class com.firebase.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# AndroidX
-keep class androidx.** { *; }
-keep interface androidx.** { *; }

# SQLite
-keep class android.database.sqlite.** { *; }

# Google Sheets & APIs
-keep class com.google.api.** { *; }
-keep class com.google.auth.** { *; }

# Kotlin Runtime
-keep class kotlin.** { *; }
-keep interface kotlin.** { *; }

# ============================================
# Custom Application Classes
# Keep our classes but obfuscate
# ============================================

-keep class com.lumbungemas.** { *; }
-keep class com.lumbungemas.lumbungemas.** { *; }
-keepclassmembers class com.lumbungemas.** { *; }

# ============================================
# Serialization & Reflection
# ============================================

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# ============================================
# Debug Information Management
# ============================================

# Remove verbose logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep line numbers for crash reporting (important for debugging)
-keepattributes SourceFile,LineNumberTable

# Remove remaining debug info safely
-renamesourcefileattribute SourceFile

# ============================================
# Suppress Warnings for Optional Google Play Core Classes
# (Used only for dynamic feature delivery, not required for base app)
# ============================================

-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Tell R8 to not fail on missing types
-dontwarn com.google.android.play.core.**

# ============================================
# Entry Points
# ============================================

# Keep main entry point
-keepclasseswithmembers class * {
    public static void main(java.lang.String[]);
}

# ============================================
# Resource Classes
# ============================================

# Keep BuildConfig
-keep class com.lumbungemas.lumbungemas.BuildConfig { *; }

# Keep R classes
-keepclassmembers class **.R$* {
    public static <fields>;
}

# ============================================
# Access Modifiers
# ============================================

# Allow access to protected members
-allowaccessmodification

# ============================================
# Optimization Settings
# ============================================

# Aggressive optimization (Java only, Dart handled separately)
-optimizationpasses 5

# Verbose output for debugging ProGuard issues
-verbose

# ============================================
# Callback/Event Handler Classes
# ============================================

# Keep event handlers commonly used in Flutter
-keepclassmembers class * {
    public void on*(...);
}

# ============================================
# Generated Classes
# ============================================

# Keep generated code from annotation processors
-keep class **_Generated* { *; }
-keep class **_Factory* { *; }

# ============================================
# IMPORTANT: Keep These for Stability
# ============================================

# Support library
-keep public class androidx.appcompat.app.AppCompatActivity
-keep public class androidx.fragment.app.Fragment

# Gson
-keep class com.google.gson.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================
# Warning Suppression (if needed)
# ============================================

# Suppress harmless warnings if needed
-dontwarn java.lang.invoke.LambdaForm$*
-dontwarn java.lang.invoke.StringConcatFactory
