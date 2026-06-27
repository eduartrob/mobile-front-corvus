allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Forzar compileSdk >= 36 y Java 17 en todos los plugins (debe coincidir con jvmTarget de Kotlin)
subprojects {
    afterEvaluate {
        if (extensions.findByName("android") != null) {
            extensions.getByType<com.android.build.gradle.BaseExtension>().apply {
                compileSdkVersion(36)
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
