package com.flutter.monetization.kit.flutter_monetization_kit_example

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.flutter.monetization.kit.flutter_monetization_kit.google_ads.GoogleNativeAdFactory

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "MonetizationNativeFactory",
            GoogleNativeAdFactory(this)
        )
    }
}
