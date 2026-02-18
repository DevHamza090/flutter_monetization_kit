package com.flutter.monetization.kit.flutter_monetization_kit.google_ads

import android.content.Context
import android.graphics.Color
import android.view.LayoutInflater
import android.widget.Button
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory

class GoogleNativeAdFactory(private val context: Context) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd, customOptions: Map<String, Any>?): NativeAdView {
        val designId = customOptions?.get("designId") as? String ?: "native1"
        
        val layoutId = context.resources.getIdentifier(designId, "layout", context.packageName)
        if (layoutId == 0) {
            throw IllegalArgumentException("Native Ad layout not found for designId: $designId. Ensure you have a layout named $designId.xml in your res/layout folder.")
        }
        
        val inflater = LayoutInflater.from(context)
        val nativeAdView = inflater.inflate(layoutId, null) as NativeAdView
        
        applyColors(nativeAdView, customOptions)
        bindAd(nativeAdView, nativeAd)
        
        return nativeAdView
    }

    private fun applyColors(nativeAdView: NativeAdView, colors: Map<String, Any>?) {
        colors?.let {
            val bgColorHex = it["backgroundColor"] as? String
            val buttonColorHex = it["buttonColor"] as? String
            val textColorHex = it["textColor"] as? String

            bgColorHex?.let { color -> nativeAdView.setBackgroundColor(Color.parseColor(color)) }
            
            val ctaView = nativeAdView.findViewById<Button>(context.resources.getIdentifier("call_to_action", "id", context.packageName))
            buttonColorHex?.let { color -> ctaView?.setBackgroundColor(Color.parseColor(color)) }
            
            val headlineView = nativeAdView.findViewById<TextView>(context.resources.getIdentifier("headline", "id", context.packageName))
            textColorHex?.let { color -> headlineView?.setTextColor(Color.parseColor(color)) }
        }
    }

    private fun bindAd(nativeAdView: NativeAdView, nativeAd: NativeAd) {
        nativeAdView.headlineView = nativeAdView.findViewById(context.resources.getIdentifier("headline", "id", context.packageName))
        nativeAdView.bodyView = nativeAdView.findViewById(context.resources.getIdentifier("body", "id", context.packageName))
        nativeAdView.callToActionView = nativeAdView.findViewById(context.resources.getIdentifier("call_to_action", "id", context.packageName))
        nativeAdView.iconView = nativeAdView.findViewById(context.resources.getIdentifier("icon", "id", context.packageName))
        nativeAdView.mediaView = nativeAdView.findViewById(context.resources.getIdentifier("media", "id", context.packageName))

        (nativeAdView.headlineView as? TextView)?.text = nativeAd.headline
        (nativeAdView.bodyView as? TextView)?.text = nativeAd.body
        (nativeAdView.callToActionView as? Button)?.text = nativeAd.callToAction
        
        nativeAdView.setNativeAd(nativeAd)
    }
}
