package com.flutter.monetization.kit.flutter_monetization_kit.google_ads

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.flutter.monetization.kit.flutter_monetization_kit.R
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class GoogleNativeAdFactory(private val context: Context) : GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(nativeAd: NativeAd, customOptions: MutableMap<String, Any>?): NativeAdView {
        val type = customOptions?.get("nativeType") as? String ?: "small1"

        // For now, mapping all small variations to the same layout
        val layoutRes = R.layout.native_ad_small
        
        val adView = LayoutInflater.from(context).inflate(layoutRes, null) as NativeAdView

        // 1. Inflate and Bind the assets
        val backgroundView = adView.findViewById<View>(R.id.ad_background)
        
        val iconView = adView.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val advertiserView = adView.findViewById<TextView>(R.id.ad_advertiser)
        val ratingBar = adView.findViewById<RatingBar>(R.id.ad_stars)
        val callToActionView = adView.findViewById<Button>(R.id.ad_call_to_action)
        val adBadgeView = adView.findViewById<TextView>(R.id.ad_badge)

        adView.iconView = iconView
        adView.headlineView = headlineView
        adView.bodyView = bodyView
        adView.advertiserView = advertiserView
        adView.starRatingView = ratingBar
        adView.callToActionView = callToActionView

        // 2. Populate data
        headlineView.text = nativeAd.headline
        
        if (nativeAd.body == null) {
            bodyView.visibility = View.INVISIBLE
        } else {
            bodyView.visibility = View.VISIBLE
            bodyView.text = nativeAd.body
        }

        if (nativeAd.callToAction == null) {
            callToActionView.visibility = View.INVISIBLE
        } else {
            callToActionView.visibility = View.VISIBLE
            callToActionView.text = nativeAd.callToAction
        }

        if (nativeAd.icon == null) {
            iconView.visibility = View.GONE
        } else {
            iconView.visibility = View.VISIBLE
            iconView.setImageDrawable(nativeAd.icon?.drawable)
        }

        if (nativeAd.advertiser == null) {
            advertiserView.visibility = View.GONE
        } else {
            advertiserView.visibility = View.VISIBLE
            advertiserView.text = nativeAd.advertiser
            // If advertiser is present, sometimes ratings are hidden
            ratingBar.visibility = View.GONE 
        }

        if (nativeAd.starRating == null) {
            ratingBar.visibility = View.GONE
        } else {
            ratingBar.visibility = View.VISIBLE
            ratingBar.rating = nativeAd.starRating!!.toFloat()
            advertiserView.visibility = View.GONE
        }

        // 3. Apply Custom Styles from Dart
        applyStyles(customOptions, backgroundView, adBadgeView, headlineView, bodyView, callToActionView)

        // Finalize
        adView.setNativeAd(nativeAd)

        return adView
    }

    private fun applyStyles(
        options: MutableMap<String, Any>?,
        backgroundView: View,
        adBadgeView: TextView,
        headlineView: TextView,
        bodyView: TextView,
        callToActionView: Button
    ) {
        if (options == null) return

        try {
            // Background
            val bgColorStr = options["bgColor"] as? String
            val bgCorner = (options["bgCorner"] as? Double)?.toFloat() ?: 8f
            
            val bgDrawable = GradientDrawable()
            bgDrawable.cornerRadius = bgCorner * context.resources.displayMetrics.density
            
            if (!bgColorStr.isNullOrEmpty() && bgColorStr.length > 10) {
                // Color formatting from Flutter: "Color(0xffffffff)"
                val hexStr = bgColorStr.substring(10, 18)
                bgDrawable.setColor(Color.parseColor("#$hexStr"))
            } else {
                bgDrawable.setColor(Color.parseColor("#FFFFFF")) // Match default or transparent
            }
            backgroundView.background = bgDrawable

            // Button
            val btnColorStr = options["buttonBgColor"] as? String
            val btnTextColorStr = options["buttonTextColor"] as? String
            val btnCorner = (options["buttonCornerRadius"] as? Double)?.toFloat() ?: 4f

            val btnDrawable = GradientDrawable()
            btnDrawable.cornerRadius = btnCorner * context.resources.displayMetrics.density
            if (!btnColorStr.isNullOrEmpty() && btnColorStr.length > 10) {
                val hexStr = btnColorStr.substring(10, 18)
                btnDrawable.setColor(Color.parseColor("#$hexStr"))
            } else {
                btnDrawable.setColor(Color.parseColor("#2196F3")) // default blue
            }
            callToActionView.background = btnDrawable

            if (!btnTextColorStr.isNullOrEmpty() && btnTextColorStr.length > 10) {
                val hexStr = btnTextColorStr.substring(10, 18)
                callToActionView.setTextColor(Color.parseColor("#$hexStr"))
            }

            // Text Colors
            val headColorStr = options["headingColor"] as? String
            if (!headColorStr.isNullOrEmpty() && headColorStr.length > 10) {
                headlineView.setTextColor(Color.parseColor("#${headColorStr.substring(10, 18)}"))
            }

            val bodyColorStr = options["bodyColor"] as? String
            if (!bodyColorStr.isNullOrEmpty() && bodyColorStr.length > 10) {
                bodyView.setTextColor(Color.parseColor("#${bodyColorStr.substring(10, 18)}"))
            }

            // Ad Badge
            val adTextColorStr = options["adTextColor"] as? String
            if (!adTextColorStr.isNullOrEmpty() && adTextColorStr.length > 10) {
                adBadgeView.setTextColor(Color.parseColor("#${adTextColorStr.substring(10, 18)}"))
            }

            val adBgColorStr = options["adTextBgColor"] as? String
            val adBgCorner = (options["adTextBgCorner"] as? Double)?.toFloat() ?: 2f
            
            val adBgDrawable = GradientDrawable()
            adBgDrawable.cornerRadius = adBgCorner * context.resources.displayMetrics.density
            if (!adBgColorStr.isNullOrEmpty() && adBgColorStr.length > 10) {
                adBgDrawable.setColor(Color.parseColor("#${adBgColorStr.substring(10, 18)}"))
            } else {
                adBgDrawable.setColor(Color.parseColor("#FFCC00"))
            }
            adBadgeView.background = adBgDrawable

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
