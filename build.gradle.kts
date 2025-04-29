plugins {
    kotlin("jvm") version "2.0.21"
    application
}

group = "org.example"
version = "1.0-SNAPSHOT"

repositories { mavenCentral() }
dependencies {
    testImplementation(kotlin("test"))
}

kotlin { jvmToolchain(17) }
tasks.test { useJUnitPlatform() }

application { mainClass.set("MainKt") }

tasks.register<JavaExec>("generateJniHeaders") {
    group = "jni"
    description = "JNI header generation task"

    val stub = file("jni-stub/NativeLib.java")

    val stubClassesDir = layout.buildDirectory.dir("jniStubClasses")

    inputs.file(stub)
    outputs.dir("src/main/cpp")

    mainClass.set("com.sun.tools.javac.Main")
    classpath = files()
    args(
        "-h", "src/main/cpp",
        "-d", stubClassesDir.get().asFile.absolutePath,
        stub.absolutePath
    )
}

tasks.named("compileKotlin") { dependsOn("generateJniHeaders") }
