import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.dsl.KotlinVersion
import java.net.URI

plugins {
    alias(libs.plugins.android.library)
    id("maven-publish")
}

android {
    namespace = "com.github.damontecres.wholphin.mpv"
    compileSdk {
        version = release(36) {
            minorApiLevel = 1
        }
    }
    ndkVersion = "29.0.14206865"
    defaultConfig {
        minSdk = 23
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        ndk{
            abiFilters += "armeabi-v7a"
            abiFilters += "arm64-v8a"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlin {
        compilerOptions {
            languageVersion = KotlinVersion.KOTLIN_2_3
            jvmTarget = JvmTarget.JVM_11
            javaParameters = true
        }
    }
    externalNativeBuild {
        ndkBuild {
            path = File("src/main/jni/Android.mk")
        }
    }
    publishing{
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

val gitDescribe: String =
    providers
        .exec { commandLine("git", "describe", "--tags", "--long", "--match=v*") }
        .standardOutput.asText
        .getOrElse("v0.0.0")
        .trim()
        .removePrefix("v")

publishing {
    publications {
        create<MavenPublication>("maven") {
            groupId = "com.github.damontecres.wholphin.mpv"
            artifactId = "wholphin-mpv"
            version = gitDescribe

            afterEvaluate {
                from(components["release"])
            }
        }
    }
    repositories{
        maven {
            name = "GitHubPackages"
            url = URI("https://maven.pkg.github.com/damontecres/wholphin-extensions")
            credentials {
                username = System.getenv("GITHUB_ACTOR")
                password = System.getenv("GITHUB_TOKEN")
            }
        }
    }
}


dependencies {

}
