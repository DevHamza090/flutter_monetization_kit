import Foundation
import Flutter
import GoogleMobileAds

public class GoogleNativeAdPlatformViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    public init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        let channel = FlutterMethodChannel(name: "monetization_native_ad_view_\(viewId)", binaryMessenger: messenger)
        return GoogleNativeAdPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger,
            channel: channel
        )
    }

    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

public class GoogleNativeAdPlatformView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private var methodChannel: FlutterMethodChannel

    public init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?,
        channel: FlutterMethodChannel
    ) {
        self._view = UIView()
        self.methodChannel = channel
        super.init()

        if let params = args as? [String: Any],
           let cacheId = params["cacheId"] as? String,
           let cachedAd = NativeAdCache.ads[cacheId] {

            let adView = buildNativeAdView(nativeAd: cachedAd, customOptions: params)
            // Use Auto Layout instead of frame-based sizing.
            // At init time `_view.bounds` is CGRect.zero (Flutter has not yet set a size),
            // so assigning frame here gives every child a zero frame — which is exactly
            // what causes the SDK's "asset outside native ad view" validation error.
            adView.translatesAutoresizingMaskIntoConstraints = false
            self._view.addSubview(adView)
            NSLayoutConstraint.activate([
                adView.topAnchor.constraint(equalTo: self._view.topAnchor),
                adView.leadingAnchor.constraint(equalTo: self._view.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: self._view.trailingAnchor),
                adView.bottomAnchor.constraint(equalTo: self._view.bottomAnchor)
            ])
        }
    }

    public func view() -> UIView {
        return _view
    }

    deinit {
        // Explicitly clear references for immediate ARC deallocation identical to Android `.destroy()`
        if let adView = _view.subviews.first as? NativeAdView {
            adView.nativeAd = nil
            adView.removeFromSuperview()
        }
    }

    private func buildNativeAdView(nativeAd: NativeAd, customOptions: [String: Any]) -> NativeAdView {
        let adView = NativeAdView()

        let bgColorStr = customOptions["bgColor"] as? String
        let bgCorner = (customOptions["bgCorner"] as? Double) ?? 8.0

        adView.backgroundColor = colorFromHex(bgColorStr) ?? UIColor.white
        adView.layer.cornerRadius = CGFloat(bgCorner)
        adView.clipsToBounds = true

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 4.0
        iconView.backgroundColor = .clear

        let badgeView = UILabel()
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        badgeView.text = "AD"
        badgeView.font = UIFont.boldSystemFont(ofSize: 10)
        badgeView.textColor = .white
        let adBgStr = customOptions["adTextBgColor"] as? String
        badgeView.backgroundColor = colorFromHex(adBgStr) ?? UIColor.systemYellow
        let adBgCorner = (customOptions["adTextBgCorner"] as? Double) ?? 2.0
        badgeView.layer.cornerRadius = CGFloat(adBgCorner)
        badgeView.clipsToBounds = true
        badgeView.textAlignment = .center

        let family = customOptions["fontFamily"] as? String
        let boldFont = registerAndGetFont(family: family, size: 14, weight: "Bold") ?? UIFont.boldSystemFont(ofSize: 14)
        let regularFont = registerAndGetFont(family: family, size: 12, weight: "Regular") ?? UIFont.systemFont(ofSize: 12)
        let smallFont = registerAndGetFont(family: family, size: 10, weight: "Regular") ?? UIFont.systemFont(ofSize: 10)

        let headlineView = UILabel()
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        headlineView.font = boldFont
        headlineView.textColor = colorFromHex(customOptions["headingColor"] as? String) ?? UIColor.black
        headlineView.numberOfLines = 1

        let bodyView = UILabel()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.font = regularFont
        bodyView.textColor = colorFromHex(customOptions["bodyColor"] as? String) ?? UIColor.darkGray

        let advertiserView = UILabel()
        advertiserView.translatesAutoresizingMaskIntoConstraints = false
        advertiserView.font = smallFont
        advertiserView.textColor = colorFromHex(customOptions["advertiserColor"] as? String) ?? UIColor.gray

        let ratingView = UILabel()
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.font = smallFont
        ratingView.textColor = colorFromHex(customOptions["ratingColor"] as? String) ?? UIColor.systemYellow

        let priceView = UILabel()
        priceView.translatesAutoresizingMaskIntoConstraints = false
        priceView.font = regularFont
        priceView.textColor = colorFromHex(customOptions["priceColor"] as? String) ?? UIColor.gray

        let actionButton = UIButton(type: .system)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = boldFont
        actionButton.setTitleColor(colorFromHex(customOptions["buttonTextColor"] as? String) ?? UIColor.white, for: .normal)
        let btnBgStr = customOptions["buttonBgColor"] as? String
        actionButton.backgroundColor = colorFromHex(btnBgStr) ?? UIColor.systemBlue
        let btnCorner = (customOptions["buttonCornerRadius"] as? Double) ?? 4.0
        actionButton.layer.cornerRadius = CGFloat(btnCorner)

        // Disable touch interactions on elements that shouldn't steal clicks, let the adView handle it.
        iconView.isUserInteractionEnabled = false
        badgeView.isUserInteractionEnabled = false
        headlineView.isUserInteractionEnabled = false
        bodyView.isUserInteractionEnabled = false
        advertiserView.isUserInteractionEnabled = false
        ratingView.isUserInteractionEnabled = false

        let padding: CGFloat = 8.0
        let type = customOptions["nativeType"] as? String ?? "small1"
        let excludeAdvertiserAndRating = ["small4", "small6", "small7", "small8", "medium1", "medium2", "medium5", "medium6"].contains(type)

        if type == "medium1" {
            applyLayoutMedium1(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               actionButton: actionButton, padding: padding)
        } else if type == "medium2" {
            applyLayoutMedium2(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               actionButton: actionButton, padding: padding)

        } else if type == "medium3" {
            applyLayoutMedium3(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               advertiserView: advertiserView, ratingView: ratingView,
                               priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "medium4" {
            applyLayoutMedium4(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               advertiserView: advertiserView, ratingView: ratingView,
                               priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "medium5" {
            applyLayoutMedium5(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               actionButton: actionButton, padding: padding)

        } else if type == "medium6" {
            applyLayoutMedium6(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               actionButton: actionButton, padding: padding)

        } else if type == "small2" || type == "small8" {
            applyLayoutSmall2_8(adView: adView, badgeView: badgeView,
                                headlineView: headlineView, bodyView: bodyView,
                                advertiserView: advertiserView, ratingView: ratingView,
                                priceView: priceView, actionButton: actionButton,
                                padding: padding, excludeAdvertiserAndRating: excludeAdvertiserAndRating)

        } else if type == "small3" || type == "small4" || type == "small5" || type == "small6" || type == "small7" {
            applyLayoutSmall3_7(adView: adView, iconView: iconView, badgeView: badgeView,
                                headlineView: headlineView, bodyView: bodyView,
                                advertiserView: advertiserView, ratingView: ratingView,
                                actionButton: actionButton, padding: padding,
                                type: type, bgCorner: bgCorner,
                                excludeAdvertiserAndRating: excludeAdvertiserAndRating)

        } else if type == "small1" {
            applyLayoutSmall1(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              actionButton: actionButton, padding: padding)


        } else if type == "large1" {
            applyLayoutLarge1(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)





        } else if type == "large2" {
            applyLayoutLarge2(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "large3" {
            applyLayoutLarge3(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "large4" {
            applyLayoutLarge4(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "large5" {
            applyLayoutLarge5(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)

        } else if type == "large6" {
            applyLayoutLarge6(adView: adView, iconView: iconView, badgeView: badgeView,
                              headlineView: headlineView, bodyView: bodyView,
                              advertiserView: advertiserView, ratingView: ratingView,
                              priceView: priceView, actionButton: actionButton, padding: padding)

        } else {
            // Default / Fallback
            applyLayoutDefault(adView: adView, iconView: iconView, badgeView: badgeView,
                               headlineView: headlineView, bodyView: bodyView,
                               advertiserView: advertiserView, ratingView: ratingView,
                               actionButton: actionButton, padding: padding)
        }

        // Populate Data
        (adView.headlineView as? UILabel)?.text = nativeAd.headline

        if let bodyText = nativeAd.body {
            (adView.bodyView as? UILabel)?.text = bodyText
        } else {
            bodyView.isHidden = true
            adView.bodyView = nil
        }

        if let ctaText = nativeAd.callToAction {
            (adView.callToActionView as? UIButton)?.setTitle(ctaText, for: .normal)
        } else {
            actionButton.isHidden = true
            adView.callToActionView = nil
        }

        if !excludeAdvertiserAndRating {
            if let adv = nativeAd.advertiser {
                (adView.advertiserView as? UILabel)?.text = adv
                ratingView.isHidden = true
                adView.starRatingView = nil
            } else if let stars = nativeAd.starRating {
                (adView.starRatingView as? UILabel)?.text = "★ \(stars)"
                advertiserView.isHidden = true
                adView.advertiserView = nil
            } else {
                advertiserView.isHidden = true
                ratingView.isHidden = true
                adView.advertiserView = nil
                adView.starRatingView = nil
            }
        }

        if let priceText = nativeAd.price {
            (adView.priceView as? UILabel)?.text = priceText
        } else {
            priceView.isHidden = true
            adView.priceView = nil
        }

        if type == "small2" || type == "small5" || type == "small6" || type == "small7" || type == "small8" {
            iconView.isHidden = true
            adView.iconView = nil
        } else if let icon = nativeAd.icon {
            iconView.image = icon.image
        } else {
            iconView.isHidden = true
            adView.iconView = nil
        }

        if nativeAd.headline == nil {
            adView.isHidden = true
            self.methodChannel.invokeMethod("onAdSized", arguments: ["height": 0.0])
            return adView
        }

        let isMediumTemplate = type == "medium1" || type == "medium2"
        let isLargeTemplate = type.hasPrefix("large")
        let isTemplateWithoutIcon = (type == "small2" || type == "small5" || type == "small6" || type == "small7" || type == "small8")

        if (nativeAd.icon == nil && !isTemplateWithoutIcon) {
            iconView.isHidden = true
            adView.iconView = nil
            // Collapse both dimensions so no gray box remains
            iconView.widthAnchor.constraint(equalToConstant: 0).isActive = true
            iconView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }

        if (isMediumTemplate || isLargeTemplate) && nativeAd.mediaContent == nil {
            adView.isHidden = true
            self.methodChannel.invokeMethod("onAdSized", arguments: ["height": 0.0])
            return adView
        }

        // Small templates have no media slot in their layout — do NOT register adView.mediaView.
        // Doing so (even with a hidden/zero-size view) causes the SDK to validate it, which
        // triggers "MediaView is too small for video" and "asset overlap" warnings.
        // Medium/large templates already have a real MediaView registered above, so this
        // block is intentionally a no-op for those too.

        adView.callToActionView?.isUserInteractionEnabled = false

        // IMPORTANT: Force a layout pass BEFORE assigning nativeAd.
        // The Google Mobile Ads SDK validates every registered asset view's frame against
        // the NativeAdView bounds at the moment nativeAd is set. If Auto Layout has not
        // run yet (e.g. the view is still CGRect.zero because Flutter hasn't passed a
        // real size yet), all child frames are zero/wrong and the SDK emits:
        //   "Advertiser assets outside native ad view —
        //    All asset boundaries must be inside the native ad view"
        // layoutIfNeeded() forces constraints to resolve so the SDK sees correct frames.
        adView.clipsToBounds = true
        adView.setNeedsLayout()
        adView.layoutIfNeeded()

        adView.nativeAd = nativeAd
        return adView
    }

    private func colorFromHex(_ hexStr: String?) -> UIColor? {
        guard let hex = hexStr, hex.hasPrefix("#") else {
            return nil
        }
        let hexColor = String(hex.dropFirst())
        var int: UInt64 = 0
        Scanner(string: hexColor).scanHexInt64(&int)

        let a, r, g, b: UInt64
        if hexColor.count == 8 {
            a = (int >> 24) & 0xFF
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else if hexColor.count == 6 {
            a = 255
            r = (int >> 16) & 0xFF
            g = (int >> 8) & 0xFF
            b = int & 0xFF
        } else {
            return nil
        }

        return UIColor(red: CGFloat(r) / 255.0,
                       green: CGFloat(g) / 255.0,
                       blue: CGFloat(b) / 255.0,
                       alpha: CGFloat(a) / 255.0)
    }

    private func registerAndGetFont(family: String?, size: CGFloat, weight: String) -> UIFont? {
        guard let family = family, !family.isEmpty else {
            return nil
        }

        // 1. Try if font is already available by PostScript Name
        if let font = UIFont(name: "\(family)-\(weight)", size: size) {
            return font
        }
        if let font = UIFont(name: family, size: size) {
            return font
        }

        // 2. Attempt to register it from the Flutter package bundle dynamically
        let assetKey = FlutterDartProject.lookupKey(forAsset: "lib/assets/fonts/\(family).ttf", fromPackage: "flutter_monetization_kit")
        if let path = Bundle.main.path(forResource: assetKey, ofType: nil),
           let data = NSData(contentsOfFile: path),
           let provider = CGDataProvider(data: data),
           let cgFont = CGFont(provider) {

            var error: Unmanaged<CFError>?
            CTFontManagerRegisterGraphicsFont(cgFont, &error)

            // Try resolving again after explicit registration
            if let font = UIFont(name: cgFont.postScriptName as String? ?? family, size: size) {
                return font
            }
        }

        // Fallback silently
        return nil
    }
}
