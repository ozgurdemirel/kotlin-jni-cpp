# Using C++ Native Libraries with Kotlin (JNI)

This is a demo project showing how to call C++ native libraries from Kotlin applications using JNI (Java Native Interface).

## Project Structure

```
kotlin-jni-cpp/
├── src/
│   ├── main/
│   │   ├── kotlin/                # Kotlin code
│   │   │   ├── Main.kt            # Main application entry point
│   │   │   └── org/example/
│   │   │       └── NativeLib.kt   # Class containing JNI calls
│   │   └── cpp/                   # C++ native code
│   │       ├── native.cpp         # C++ implementation
│   │       └── org_example_NativeLib.h  # JNI header file
│   └── test/                      # Test code
├── jni-stub/
│   └── NativeLib.java             # Stub for generating JNI header file
├── Makefile                       # Build file for the native library
├── build.gradle.kts               # Gradle configuration
└── gradle/                        # Gradle wrapper files
```

## How It Works

### 1. Kotlin Side

In Kotlin, use the `external` keyword to declare native methods:

```kotlin
package org.example

object NativeLib {
    init {
        // Load the native library (e.g., libnative.so, .dylib, or .dll)
        System.loadLibrary("native")
    }

    // Native functions implemented in C++
    external fun add(a: Int, b: Int): Int
    external fun greet(): String
}
```

Call these functions from your main program:

```kotlin
import org.example.NativeLib

fun main() {
    val x = 5
    val y = 7
    val sum = NativeLib.add(x, y)
    println("$x + $y = $sum")

    val message = NativeLib.greet()
    println("Message from C++: $message")
}
```

### 2. C++ Side

In C++, JNI functions must follow a specific naming convention: `Java_package_name_ClassName_methodName`.

```cpp
#include <jni.h>      // JNI header
#include <string>     // For using std::string

extern "C" { // To prevent C++ name mangling

    // Implementation for add(int, int)
    JNIEXPORT jint JNICALL Java_org_example_NativeLib_add(JNIEnv* env, jobject thiz, jint a, jint b)
    {
        return a + b;
    }

    // Implementation for greet()
    JNIEXPORT jstring JNICALL Java_org_example_NativeLib_greet(JNIEnv* env, jobject thiz)
    {
        std::string msg = "Hello from C++";
        // Convert C++ string to Java string (jstring)
        return env->NewStringUTF(msg.c_str());
    }
}
```

* `JNIEnv* env`: A pointer to the JNI environment, used to interact with the Java VM.
* `jobject thiz`: A reference to the calling Kotlin/Java object (NativeLib in this case).

## Gradle Configuration for JNI Headers

A key aspect of this project is how we generate JNI header files automatically using Gradle. The following configuration in `build.gradle.kts` creates a custom task to generate C++ header files from Java stubs:

```kotlin
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
```

This configuration:
- Creates a custom Gradle task named `generateJniHeaders`
- Uses a Java stub file (`jni-stub/NativeLib.java`) as input
- Invokes the JDK's `javac` tool to generate header files
- Places the generated headers in `src/main/cpp` directory
- Makes the Kotlin compilation depend on this header generation

The benefit of this approach is that you don't need to manually run `javah` or other tools to generate JNI headers - they're automatically created as part of the build process.

## Setup and Run

### Requirements

- JDK 17 or higher
- Kotlin 2.0+
- C++ compiler (GCC, Clang, or MSVC)
- Gradle 8.0+

### Build and Run Steps

1. **Generate JNI Headers**: Creates the .h file needed for the C++ side.
   ```bash
   ./gradlew generateJniHeaders
   ```
   This task uses `jni-stub/NativeLib.java` to generate `src/main/cpp/org_example_NativeLib.h`.

2. **Compile Native Library**: Compiles the C++ code into a shared library (.so, .dylib, or .dll).
   ```bash
   make
   ```
   The Makefile detects the OS and builds the library accordingly.

3. **Run the Application**: Executes the Kotlin code.
   ```bash
   ./gradlew run
   ```

Alternatively, run all steps with:
```bash
make run
```

## Important Notes

1. **Data Types**: JNI handles conversions between Kotlin/Java types and C++ types. Primitives like Int map directly to jint. Reference types like String require using JNIEnv functions (e.g., NewStringUTF).

2. **Memory Management**: Be mindful of memory allocated in C++. JNI provides functions to manage Java objects created in native code.

3. **Error Handling**: C++ exceptions can be converted to Java exceptions using JNI functions.

4. **Thread Safety**: Be careful when calling native methods from multiple threads. The JNIEnv pointer is typically valid only for the thread it belongs to.

## Resources

- [JNI Specification](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/spec/jniTOC.html)
- [Kotlin Native](https://kotlinlang.org/docs/native-overview.html)
- [Java JNI Programming Tutorial](https://www3.ntu.edu.sg/home/ehchua/programming/java/JavaNativeInterface.html)

## License

This project is distributed under the MIT license.

---

This demo provides a basic example of integrating Kotlin and C++ using JNI. For more complex applications, additional JNI features may be required.