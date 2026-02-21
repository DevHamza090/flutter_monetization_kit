package com.flutter.monetization.kit.flutter_monetization_kit

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import com.flutter.monetization.kit.flutter_monetization_kit.google_ads.GoogleNativeAdPlatformViewFactory
import com.flutter.monetization.kit.flutter_monetization_kit.google_ads.NativeAdCache
import com.google.android.gms.ads.AdListener
import com.google.android.gms.ads.AdLoader
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.LoadAdError
import com.google.android.gms.ads.nativead.NativeAdOptions
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterMonetizationKitPlugin */
class FlutterMonetizationKitPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "flutter_monetization_kit/native_ads")
        channel.setMethodCallHandler(this)
        
        binding.platformViewRegistry.registerViewFactory(
            "monetization_native_ad_view",
            GoogleNativeAdPlatformViewFactory(context, binding.flutterAssets) { viewId ->
                MethodChannel(binding.binaryMessenger, "monetization_native_ad_view_$viewId")
            }
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${android.os.Build.VERSION.RELEASE}")
            "loadAd" -> {
                val cacheId = call.argument<String>("cacheId") ?: return
                val adUnitId = call.argument<String>("adUnitId") ?: return
                loadNativeAd(cacheId, adUnitId)
                result.success(null)
            }
            "disposeAd" -> {
                val cacheId = call.argument<String>("cacheId") ?: return
                NativeAdCache.ads[cacheId]?.destroy()
                NativeAdCache.ads.remove(cacheId)
                result.success(null)
            }
            "consumeAd" -> {
                val cacheId = call.argument<String>("cacheId") ?: return
                NativeAdCache.ads.remove(cacheId)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun loadNativeAd(cacheId: String, adUnitId: String) {
        val adLoader = AdLoader.Builder(context, adUnitId)
            .forNativeAd { nativeAd ->
                NativeAdCache.ads[cacheId] = nativeAd
                channel.invokeMethod("onAdLoaded", mapOf("cacheId" to cacheId, "adUnitId" to adUnitId))
            }
            .withAdListener(object : AdListener() {
                override fun onAdFailedToLoad(error: LoadAdError) {
                    channel.invokeMethod("onAdFailedToLoad", mapOf(
                        "cacheId" to cacheId,
                        "adUnitId" to adUnitId,
                        "error" to error.message
                    ))
                }
            })
            .withNativeAdOptions(NativeAdOptions.Builder().build())
            .build()
            
        adLoader.loadAd(AdRequest.Builder().build())
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    companion object {
        @JvmStatic
        fun registerNativeAdFactory(engine: FlutterEngine, context: Context) {
            // Deprecated natively. UI is now built at PlatformView layer using Flutter bindings directly dynamically.
        }

        @JvmStatic
        fun unregisterNativeAdFactory(engine: FlutterEngine) {
            // Deprecated
        }
    }
}
