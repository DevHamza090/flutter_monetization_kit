import Flutter
import UIKit
import google_mobile_ads

public class FlutterMonetizationKitPlugin: NSObject, FlutterPlugin, GADNativeAdLoaderDelegate {
    private var channel: FlutterMethodChannel?
    private var adLoaders: [String: GADAdLoader] = [:]
    private var cacheIdMap: [String: String] = [:] // Maps adLoader to cacheId for callback tracking
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_monetization_kit", binaryMessenger: registrar.messenger())
        let instance = FlutterMonetizationKitPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let nativeChannel = FlutterMethodChannel(name: "flutter_monetization_kit/native_ads", binaryMessenger: registrar.messenger())
        instance.channel = nativeChannel
        registrar.addMethodCallDelegate(instance, channel: nativeChannel)
        
        let factory = GoogleNativeAdPlatformViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "monetization_native_ad_view")
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "requestTrackingAuthorization" {
            ATTManager.requestAuthorization { status in
                result(status)
            }
        } else if call.method == "loadAd" {
            guard let args = call.arguments as? [String: Any],
                  let cacheId = args["cacheId"] as? String,
                  let adUnitId = args["adUnitId"] as? String else {
                result(nil)
                return
            }
            loadNativeAd(cacheId: cacheId, adUnitId: adUnitId)
            result(nil)
        } else if call.method == "disposeAd" {
            guard let args = call.arguments as? [String: Any],
                  let cacheId = args["cacheId"] as? String else {
                result(nil)
                return
            }
            NativeAdCache.ads.removeValue(forKey: cacheId)
            result(nil)
        } else if call.method == "consumeAd" {
            guard let args = call.arguments as? [String: Any],
                  let cacheId = args["cacheId"] as? String else {
                result(nil)
                return
            }
            NativeAdCache.ads.removeValue(forKey: cacheId)
            result(nil)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func loadNativeAd(cacheId: String, adUnitId: String) {
        guard let window = UIApplication.shared.windows.first, let rootVC = window.rootViewController else { return }
        
        let adLoader = GADAdLoader(
            adUnitID: adUnitId,
            rootViewController: rootVC,
            adTypes: [.native],
            options: nil
        )
        
        adLoader.delegate = self
        adLoaders[adUnitId] = adLoader
        cacheIdMap[adUnitId] = cacheId
        
        adLoader.load(GADRequest())
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        guard let adUnitId = adLoader.adUnitID, let cacheId = cacheIdMap[adUnitId] else { return }
        
        NativeAdCache.ads[cacheId] = nativeAd
        channel?.invokeMethod("onAdLoaded", arguments: ["cacheId": cacheId, "adUnitId": adUnitId])
        
        // Clean up
        adLoaders.removeValue(forKey: adUnitId)
        cacheIdMap.removeValue(forKey: adUnitId)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        guard let adUnitId = adLoader.adUnitID, let cacheId = cacheIdMap[adUnitId] else { return }
        
        channel?.invokeMethod("onAdFailedToLoad", arguments: ["cacheId": cacheId, "adUnitId": adUnitId, "error": error.localizedDescription])
        
        // Clean up
        adLoaders.removeValue(forKey: adUnitId)
        cacheIdMap.removeValue(forKey: adUnitId)
    }
}
