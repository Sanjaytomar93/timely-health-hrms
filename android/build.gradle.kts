allprojects {
    repositories {
        google()
        mavenCentral()
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

// Register BEFORE evaluationDependsOn — upgrades plugin Java 8 → 17
// (silences "source value 8 is obsolete") and keeps Kotlin in sync.
subprojects {
    afterEvaluate {
        tasks.withType<JavaCompile>().configureEach {
            sourceCompatibility = "17"
            targetCompatibility = "17"
            options.compilerArgs.add("-Xlint:-options")
        }

        extensions.findByName("android")?.let { androidExt ->
            try {
                val compileOptions =
                    androidExt.javaClass.getMethod("getCompileOptions").invoke(androidExt)
                compileOptions.javaClass
                    .getMethod("setSourceCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
                compileOptions.javaClass
                    .getMethod("setTargetCompatibility", JavaVersion::class.java)
                    .invoke(compileOptions, JavaVersion.VERSION_17)
            } catch (_: Throwable) {
                // ignore
            }
            try {
                val kotlinOptions =
                    androidExt.javaClass.getMethod("getKotlinOptions").invoke(androidExt)
                kotlinOptions.javaClass
                    .getMethod("setJvmTarget", String::class.java)
                    .invoke(kotlinOptions, "17")
            } catch (_: Throwable) {
                // ignore
            }
        }

        try {
            val kotlinCompile =
                Class.forName("org.jetbrains.kotlin.gradle.tasks.KotlinCompile")
            @Suppress("UNCHECKED_CAST")
            tasks.withType(kotlinCompile as Class<Task>).configureEach {
                try {
                    val opts = javaClass.getMethod("getKotlinOptions").invoke(this)
                    opts.javaClass
                        .getMethod("setJvmTarget", String::class.java)
                        .invoke(opts, "17")
                } catch (_: Throwable) {
                    // ignore
                }
            }
        } catch (_: ClassNotFoundException) {
            // no kotlin in this module
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
