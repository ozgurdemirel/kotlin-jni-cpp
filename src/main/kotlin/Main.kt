import org.example.NativeLib

fun main() {
    val x = 5
    val y = 7
    val sum = NativeLib.add(x, y)
    println("$x + $y = $sum")

    val message = NativeLib.greet()
    println("out : $message")
}
