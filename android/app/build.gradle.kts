plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // ফায়ারবেস সার্ভিস প্লাগিন যুক্ত হলো
}

android {
    namespace = "com.mtsoftai.moviflix"
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
        applicationId = "com.mtsoftai.moviflix"
        minSdk = flutter.minSdkVersion // ফায়ারবেস এবং অ্যাডমোবের জন্য minSdk 21 করা হলো
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// ফায়ারবেস BOM এবং অ্যানালিটিক্স ডিপেন্ডেন্সি যুক্ত হলো
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    implementation("com.google.firebase:firebase-analytics")
}
