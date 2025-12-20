plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// loading .env file for api key string
import java.util.Properties
import org.gradle.api.GradleException
val dotenv = Properties()
val envFile = rootProject.file("../.env")
if (!envFile.exists()) {
    throw GradleException(
        "Missing .env file. Expected at: ${envFile.absolutePath}"
    )
}
envFile.inputStream().use { dotenv.load(it) }
val mapsApiKey = dotenv.getProperty("GOOGLE_MAPS_SDK_ANDROID_API_KEY")
    ?: throw GradleException(
        "Missing GOOGLE_MAPS_SDK_ANDROID_API_KEY in .env"
    )
// end of loading from .env file

android {
    namespace = "it.pantani.carbur_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "it.pantani.carbur_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["mapsApiKey"] = mapsApiKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
