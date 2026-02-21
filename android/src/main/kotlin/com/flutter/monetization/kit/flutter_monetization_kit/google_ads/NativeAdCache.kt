package com.flutter.monetization.kit.flutter_monetization_kit.google_ads

import com.google.android.gms.ads.nativead.NativeAd

object NativeAdCache {
    // Stores loaded NativeAds mapped by cacheId
    val ads = mutableMapOf<String, NativeAd>()
}
