import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// RG-20: release imzosi. Kalitlar repozitoriyda YO‘Q:
//  * `android/key.properties` (gitignore’da; namuna: key.properties.example), yoki
//  * CI sirlari: FE_KEYSTORE_PATH, FE_KEYSTORE_PASSWORD, FE_KEY_ALIAS,
//    FE_KEY_PASSWORD.
// Hech biri bo‘lmasa — debug imzo (faqat lokal sinov) va ogohlantirish.
// Store uchun build: `-PrequireReleaseSigning=true` — kalitsiz build to‘xtaydi.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) FileInputStream(f).use { load(it) }
}
fun signingValue(prop: String, env: String): String? =
    (keystoreProperties.getProperty(prop) ?: System.getenv(env))?.takeIf { it.isNotBlank() }
val releaseStoreFile = signingValue("storeFile", "FE_KEYSTORE_PATH")
val hasReleaseSigning = releaseStoreFile != null &&
    signingValue("storePassword", "FE_KEYSTORE_PASSWORD") != null &&
    signingValue("keyAlias", "FE_KEY_ALIAS") != null &&
    signingValue("keyPassword", "FE_KEY_PASSWORD") != null
val requireReleaseSigning =
    (project.findProperty("requireReleaseSigning") as String?)?.toBoolean() == true

android {
    namespace = "uz.forensicexpert.forensic_expert"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "uz.forensicexpert.forensic_expert"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = signingValue("storePassword", "FE_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "FE_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "FE_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                if (requireReleaseSigning) {
                    throw GradleException(
                        "RG-20: release signing required but no keystore configured " +
                            "(android/key.properties or FE_KEYSTORE_* environment).",
                    )
                }
                logger.warn(
                    "RG-20: release build is signed with the DEBUG key — not for store upload.",
                )
                signingConfigs.getByName("debug")
            }

            // Native debug symbols (~91 MB uncompressed) only serve Play's
            // native crash reports; they never reach a user's device, but they
            // double the size of the bundle we have to download and upload by
            // hand. Set FE_NATIVE_DEBUG_SYMBOLS=full before a build when a
            // native crash actually needs symbolicating.
            ndk {
                debugSymbolLevel =
                    System.getenv("FE_NATIVE_DEBUG_SYMBOLS")?.takeIf { it.isNotBlank() }
                        ?: "none"
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
