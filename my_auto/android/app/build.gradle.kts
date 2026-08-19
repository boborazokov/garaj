plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase Messaging requires the google-services plugin to be applied
    // so the generated values from google-services.json are merged into
    // the app's resources at build time.
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.my_auto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // flutter_local_notifications uses Java 8+ APIs (LocalDateTime, etc.)
        // through desugaring on minSdk < 26.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "garaj.uz"
        // Firebase Messaging requires min SDK 21; flutter_local_notifications 17+
        // requires min SDK 21 as well. Lock it here so the merge can't regress.
        // flutter_local_notifications 21+ requires minSdk 24.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Replace with proper signing config before publishing.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring runtime for Android API < 26 builds.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

}
