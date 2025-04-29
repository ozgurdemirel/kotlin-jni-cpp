#include <jni.h>
#include <string>

extern "C" {
    // int add(int, int)
    JNIEXPORT jint JNICALL Java_org_example_NativeLib_add(JNIEnv*, jobject, jint a, jint b)
    {
        return a + b;
    }

    // String greet()
    JNIEXPORT jstring JNICALL Java_org_example_NativeLib_greet(JNIEnv* env, jobject)
    {
        std::string msg = "Hello from C++";
        return env->NewStringUTF(msg.c_str());
    }
}
