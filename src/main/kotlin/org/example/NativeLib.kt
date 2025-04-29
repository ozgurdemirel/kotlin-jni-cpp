package org.example


object NativeLib {
    init {
        // "native" (libnative.so, .dylib veya .dll)
        System.loadLibrary("native")
    }

    external fun add(a: Int, b: Int): Int
    external fun greet(): String
}
