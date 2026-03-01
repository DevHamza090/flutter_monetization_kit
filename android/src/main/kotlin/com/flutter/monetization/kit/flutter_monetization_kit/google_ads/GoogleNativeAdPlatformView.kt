package com.flutter.monetization.kit.flutter_monetization_kit.google_ads

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.Typeface
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
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterAssets

class GoogleNativeAdPlatformViewFactory(
    private val context: Context,
    private val flutterAssets: FlutterAssets,
    private val channelProvider: (Int) -> MethodChannel
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String, Any?>
        val channel = channelProvider(viewId)
        return GoogleNativeAdPlatformView(context, flutterAssets, viewId, creationParams, channel)
    }
}

class GoogleNativeAdPlatformView(
    private val context: Context,
    private val flutterAssets: FlutterAssets,
    id: Int,
    private val creationParams: Map<String, Any?>?,
    private val methodChannel: MethodChannel
) : PlatformView {

    private var adView: NativeAdView? = null
    private var currentNativeAd: NativeAd? = null

    init {
        val cacheId = creationParams?.get("cacheId") as? String
        val cachedAd = if (cacheId != null) NativeAdCache.ads[cacheId] else null

        if (cachedAd != null) {
            currentNativeAd = cachedAd
            adView = buildNativeAdView(cachedAd, creationParams)
        }
    }

    override fun getView(): View? {
        return adView
    }

    override fun dispose() {
        adView?.destroy()
        currentNativeAd?.destroy()
        adView = null
        currentNativeAd = null
    }

    private fun buildNativeAdView(nativeAd: NativeAd, options: Map<String, Any?>?): NativeAdView {
        val type = options?.get("nativeType") as? String ?: "small1"
        val layoutRes = if (type == "small8") {
            R.layout.native_ad_small_8
        } else if (type == "small7") {
            R.layout.native_ad_small_7
        } else if (type == "small6") {
            R.layout.native_ad_small_6
        } else if (type == "small5") {
            R.layout.native_ad_small_5
        } else if (type == "small4") {
            R.layout.native_ad_small_4
        } else if (type == "small3") {
            R.layout.native_ad_small_3
        } else if (type == "small2") {
            R.layout.native_ad_small_2
        } else {
            R.layout.native_ad_small
        }
        val view = LayoutInflater.from(context).inflate(layoutRes, null) as NativeAdView

        // 1. Inflate and Bind the assets
        val backgroundView = view.findViewById<View>(R.id.ad_background)
        val iconView = view.findViewById<ImageView>(R.id.ad_app_icon)
        val headlineView = view.findViewById<TextView>(R.id.ad_headline)
        val bodyView = view.findViewById<TextView>(R.id.ad_body)
        val advertiserView = view.findViewById<TextView?>(R.id.ad_advertiser)
        val ratingBar = view.findViewById<RatingBar?>(R.id.ad_stars)
        val callToActionView = view.findViewById<Button>(R.id.ad_call_to_action)
        val adBadgeView = view.findViewById<TextView>(R.id.ad_badge)

        view.iconView = iconView
        view.headlineView = headlineView
        view.bodyView = bodyView
        view.advertiserView = advertiserView
        view.starRatingView = ratingBar
        val priceView = view.findViewById<TextView>(R.id.ad_price)
        view.priceView = priceView

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
            iconView?.visibility = View.GONE
        } else {
            iconView?.visibility = View.VISIBLE
            iconView?.setImageDrawable(nativeAd.icon?.drawable)
        }

        if (nativeAd.advertiser == null) {
            advertiserView?.visibility = View.GONE
        } else {
            advertiserView?.visibility = View.VISIBLE
            advertiserView?.text = nativeAd.advertiser
            ratingBar?.visibility = View.GONE 
        }

        if (nativeAd.starRating == null) {
            ratingBar?.visibility = View.GONE
        } else {
            ratingBar?.visibility = View.VISIBLE
            ratingBar?.rating = nativeAd.starRating!!.toFloat()
            advertiserView?.visibility = View.GONE
        }
        
        if (nativeAd.price == null) {
            priceView?.visibility = View.GONE
        } else {
            priceView?.visibility = View.VISIBLE
            priceView?.text = nativeAd.price
        }

        applyStyles(options, type, backgroundView, adBadgeView, headlineView, bodyView, callToActionView, ratingBar, advertiserView, priceView)

        view.setNativeAd(nativeAd)
        return view
    }

    private fun applyStyles(
        options: Map<String, Any?>?,
        type: String,
        backgroundView: View,
        adBadgeView: TextView,
        headlineView: TextView,
        bodyView: TextView,
        callToActionView: Button,
        ratingBar: RatingBar?,
        advertiserView: TextView?,
        priceView: TextView?
    ) {
        if (options == null) return

        try {
            // Background
            val bgColorStr = options["bgColor"] as? String // e.g. #FF1E1E1E
            val bgCorner = (options["bgCorner"] as? Double)?.toFloat() ?: 8f
            
            val bgDrawable = GradientDrawable()
            bgDrawable.cornerRadius = bgCorner * context.resources.displayMetrics.density
            
            if (!bgColorStr.isNullOrEmpty() && bgColorStr.length >= 7) {
                bgDrawable.setColor(Color.parseColor(bgColorStr))
            } else {
                bgDrawable.setColor(Color.parseColor("#FFFFFF"))
            }
            backgroundView.background = bgDrawable

            // Button
            val btnColorStr = options["buttonBgColor"] as? String
            val btnTextColorStr = options["buttonTextColor"] as? String
            val btnCorner = (options["buttonCornerRadius"] as? Double)?.toFloat() ?: 4f

            val btnDrawable = GradientDrawable()
            if (type == "small3" || type == "small4" || type == "small6" || type == "small7") {
                val cr = bgCorner * context.resources.displayMetrics.density
                btnDrawable.cornerRadii = floatArrayOf(
                    0f, 0f, // Top-Left
                    cr, cr, // Top-Right
                    cr, cr, // Bottom-Right
                    0f, 0f  // Bottom-Left
                )
            } else {
                btnDrawable.cornerRadius = btnCorner * context.resources.displayMetrics.density
            }
            if (!btnColorStr.isNullOrEmpty() && btnColorStr.length >= 7) {
                btnDrawable.setColor(Color.parseColor(btnColorStr))
            } else {
                btnDrawable.setColor(Color.parseColor("#2196F3"))
            }
            callToActionView.background = btnDrawable

            if (!btnTextColorStr.isNullOrEmpty() && btnTextColorStr.length >= 7) {
                callToActionView.setTextColor(Color.parseColor(btnTextColorStr))
            }

            // Text Colors
            val headColorStr = options["headingColor"] as? String
            if (!headColorStr.isNullOrEmpty() && headColorStr.length >= 7) {
                headlineView.setTextColor(Color.parseColor(headColorStr))
            }

            val bodyColorStr = options["bodyColor"] as? String
            if (!bodyColorStr.isNullOrEmpty() && bodyColorStr.length >= 7) {
                bodyView.setTextColor(Color.parseColor(bodyColorStr))
            }
            
            val maxBodyLines = options["maxBodyLines"] as? Int
            if (maxBodyLines != null) {
                bodyView.maxLines = maxBodyLines
            }

            val advertiserColorStr = options["advertiserColor"] as? String
            if (!advertiserColorStr.isNullOrEmpty() && advertiserColorStr.length >= 7) {
                advertiserView?.setTextColor(Color.parseColor(advertiserColorStr))
            }
            
            val priceColorStr = options["priceColor"] as? String
            if (!priceColorStr.isNullOrEmpty() && priceColorStr.length >= 7) {
                priceView?.setTextColor(Color.parseColor(priceColorStr))
            }

            // Ratings
            val ratingColorStr = options["ratingColor"] as? String
            val ratingBgColorStr = options["ratingBgColor"] as? String
            if (!ratingColorStr.isNullOrEmpty() && ratingColorStr.length >= 7) {
                ratingBar?.progressTintList = ColorStateList.valueOf(Color.parseColor(ratingColorStr))
            }
            if (!ratingBgColorStr.isNullOrEmpty() && ratingBgColorStr.length >= 7) {
                ratingBar?.progressBackgroundTintList = ColorStateList.valueOf(Color.parseColor(ratingBgColorStr))
            }

            // Ad Badge
            val adTextColorStr = options["adTextColor"] as? String
            if (!adTextColorStr.isNullOrEmpty() && adTextColorStr.length >= 7) {
                adBadgeView.setTextColor(Color.parseColor(adTextColorStr))
            }

            val adBgColorStr = options["adTextBgColor"] as? String
            val adBgCorner = (options["adTextBgCorner"] as? Double)?.toFloat() ?: 2f
            
            val adBgDrawable = GradientDrawable()
            adBgDrawable.cornerRadius = adBgCorner * context.resources.displayMetrics.density
            if (!adBgColorStr.isNullOrEmpty() && adBgColorStr.length >= 7) {
                adBgDrawable.setColor(Color.parseColor(adBgColorStr))
            } else {
                adBgDrawable.setColor(Color.parseColor("#FFCC00"))
            }
            adBadgeView.background = adBgDrawable

            // Fonts
            val fontFamilyStr = options["fontFamily"] as? String
            if (!fontFamilyStr.isNullOrEmpty()) {
                try {
                     val fontKey = flutterAssets.getAssetFilePathByName("lib/assets/fonts/$fontFamilyStr.ttf", "flutter_monetization_kit")
                     val customTypeface = Typeface.createFromAsset(context.assets, fontKey)
                     headlineView.typeface = customTypeface
                     bodyView.typeface = customTypeface
                     callToActionView.typeface = customTypeface
                     advertiserView?.typeface = customTypeface
                     adBadgeView.typeface = customTypeface
                } catch (e: Exception) {
                     // Fallback to manual placing inside main project
                     try {
                         val fallbackTypeface = Typeface.createFromAsset(context.assets, "fonts/$fontFamilyStr.ttf")
                         headlineView.typeface = fallbackTypeface
                         bodyView.typeface = fallbackTypeface
                         callToActionView.typeface = fallbackTypeface
                         advertiserView?.typeface = fallbackTypeface
                         adBadgeView.typeface = fallbackTypeface
                     } catch (e2: Exception) {
                         // Fallback silently if asset font doesn't match name exactly
                     }
                }
            }

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
