package uz.forensicexpert.forensic_expert

import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // «Darslar» ko'rish oynasi ochiq turganda skrinshot/yozib olishni
        // cheklaydi (FLAG_SECURE); yopilganda olib tashlanadi.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "uz.forensicexpert/secure_screen"
        ).setMethodCallHandler { call, result ->
            if (call.method == "setSecure") {
                val on = call.arguments as? Boolean ?: false
                runOnUiThread {
                    if (on) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
