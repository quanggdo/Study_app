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

subprojects {
    project.evaluationDependsOn(":app")
}

// Workaround for "Namespace not specified" error in older plugins like isar_flutter_libs
subprojects {
    // Tránh dùng afterEvaluate vì có thể bị gọi khi project đã evaluated (Gradle 8/AGP 8+).
    // Thay vào đó, hook theo plugin Android để set namespace sớm và an toàn hơn.
    plugins.withId("com.android.library") {
        val android = project.extensions.findByName("android") ?: return@withId
        try {
            val namespaceMethod = android.javaClass.getMethod("setNamespace", String::class.java)
            val getNamespaceMethod = android.javaClass.getMethod("getNamespace")
            if (getNamespaceMethod.invoke(android) == null) {
                val defaultNamespace =
                    "com.example.student_academic_assistant.${project.name.replace("-", "_")}"
                namespaceMethod.invoke(android, defaultNamespace)
            }
        } catch (_: Exception) {
            // ignore
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
