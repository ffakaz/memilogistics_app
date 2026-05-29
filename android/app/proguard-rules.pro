# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }

# Google Play Core (Required by Flutter)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep all model classes for JSON serialization
-keep class com.example.memilogistics_app.** { *; }

# Keep ALL Dart classes (prevents stripping of Flutter code)
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Dart VM classes
-keep class com.google.dart.** { *; }
-dontwarn com.google.dart.**

# Keep data models
-keep class * extends java.lang.Object {
    <fields>;
    <methods>;
}

# Preserve line number information for debugging stack traces
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name
#-renamesourcefileattribute SourceFile

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters in Views so that animations can still work
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}

# Keep classes that are referenced on the AndroidManifest
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# For enumeration classes
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelables
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

# Dio HTTP client - CRITICAL for API calls
-keep class io.flutter.plugins.** { *; }
-keep class dio.** { *; }
-dontwarn dio.**

# HTTP and networking classes
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Retrofit/HTTP annotations (if used)
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations

# Flutter Secure Storage - CRITICAL for token persistence
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class com.it_nomads.** { *; }

# Android Keystore (used by Flutter Secure Storage)
-keep class android.security.keystore.** { *; }
-keep class javax.crypto.** { *; }
-dontwarn javax.crypto.**

# SharedPreferences (used by Flutter Secure Storage on Android)
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$** { *; }
-keep class androidx.security.crypto.** { *; }
-dontwarn androidx.security.crypto.**

# EncryptedSharedPreferences - CRITICAL
-keep class androidx.security.crypto.EncryptedSharedPreferences { *; }
-keep class androidx.security.crypto.EncryptedSharedPreferences$** { *; }
-keep class androidx.security.crypto.MasterKey { *; }
-keep class androidx.security.crypto.MasterKey$** { *; }

# Keep all annotations
-keepattributes *Annotation*,Signature,Exception

# Keep method names (prevents breaking reflection and serialization)
-keepattributes MethodParameters
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Don't obfuscate - CRITICAL for debugging and reflection
-dontobfuscate

# Prevent obfuscation of JSON field names
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep JSON serialization methods
-keepclassmembers class * {
    public <init>(org.json.JSONObject);
}

# Keep fromJson and toJson methods
-keepclassmembers class * {
    public static ** fromJson(java.util.Map);
    public java.util.Map toJson();
}

# Suppress warnings for missing classes
-dontwarn javax.lang.model.element.Modifier
-dontwarn com.google.errorprone.annotations.**
