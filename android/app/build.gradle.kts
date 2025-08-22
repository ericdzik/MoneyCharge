plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.locacharge"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.locacharge"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Limiter les architectures pour réduire la mémoire utilisée
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a") // x86 et x86_64 non nécessaires
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")

            // Désactiver temporairement R8/shrinker si build échoue
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Optionnel : augmentation du max heap pour le dexer et le compiler
    dexOptions {
        javaMaxHeapSize = "8g"
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
