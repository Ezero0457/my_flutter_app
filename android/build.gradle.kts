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
    afterEvaluate {
        if (project.plugins.hasPlugin("com.android.library")) {
            val android = project.extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
            if (android.namespace.isNullOrEmpty()) {
                val manifest = file("${project.projectDir}/src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val packageName = javax.xml.parsers.DocumentBuilderFactory.newInstance()
                        .newDocumentBuilder()
                        .parse(manifest)
                        .documentElement
                        .getAttribute("package")
                    if (packageName.isNotEmpty()) {
                        android.namespace = packageName
                    }
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
