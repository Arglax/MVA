import java.util.Properties

plugins {
    id("com.android.application")
}

val telemetry = Properties().apply {
    val f = rootProject.file("telemetry.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

val signing = Properties().apply {
    val f = rootProject.file("signing.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}

android {
    namespace = "com.arglax.mva"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.arglax.mva"
        minSdk = 28
        targetSdk = 36
        versionCode = 7
        versionName = "1.0.0"
        buildConfigField("String", "TELEMETRY_KEY", "\"" + (telemetry.getProperty("apiKey") ?: "") + "\"")
        buildConfigField("String", "TELEMETRY_PROJECT", "\"" + (telemetry.getProperty("projectId") ?: "") + "\"")
    }
    buildFeatures {
        buildConfig = true
    }
    sourceSets["main"].assets.srcDirs("../../web")
    androidResources {
        ignoreAssetsPattern = "!*.map:!.*:!VERSION"
    }
    signingConfigs {
        create("release") {
            if (signing.getProperty("storeFile") != null) {
                storeFile = rootProject.file(signing.getProperty("storeFile"))
                storePassword = signing.getProperty("storePassword")
                keyAlias = signing.getProperty("keyAlias")
                keyPassword = signing.getProperty("keyPassword")
            }
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = false
            if (signing.getProperty("storeFile") != null) signingConfig = signingConfigs.getByName("release")
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

if (signing.getProperty("storeFile") == null) {
    gradle.taskGraph.whenReady {
        if (allTasks.any { it.path == ":app:packageRelease" || it.path == ":app:packageReleaseBundle" })
            throw GradleException("Release build: android/signing.properties is missing (storeFile, storePassword, keyAlias, keyPassword). Debug builds do not need it.")
    }
}

configurations.matching { it.name == "debugRuntimeClasspath" || it.name == "releaseRuntimeClasspath" }.configureEach {
    exclude(group = "org.jetbrains.kotlin", module = "kotlin-stdlib")
    exclude(group = "org.jetbrains", module = "annotations")
}
