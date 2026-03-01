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
            adView.frame = self._view.bounds
            adView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self._view.addSubview(adView)
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
        iconView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        adView.addSubview(iconView)
        adView.iconView = iconView
        
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
        adView.addSubview(badgeView)
        
        let family = customOptions["fontFamily"] as? String
        let boldFont = registerAndGetFont(family: family, size: 14, weight: "Bold") ?? UIFont.boldSystemFont(ofSize: 14)
        let regularFont = registerAndGetFont(family: family, size: 12, weight: "Regular") ?? UIFont.systemFont(ofSize: 12)
        let smallFont = registerAndGetFont(family: family, size: 10, weight: "Regular") ?? UIFont.systemFont(ofSize: 10)
        
        let headlineView = UILabel()
        headlineView.translatesAutoresizingMaskIntoConstraints = false
        headlineView.font = boldFont
        headlineView.textColor = colorFromHex(customOptions["headingColor"] as? String) ?? UIColor.black
        headlineView.numberOfLines = 1
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        
        let bodyView = UILabel()
        bodyView.translatesAutoresizingMaskIntoConstraints = false
        bodyView.font = regularFont
        bodyView.textColor = colorFromHex(customOptions["bodyColor"] as? String) ?? UIColor.darkGray
        let maxBodyLines = customOptions["maxBodyLines"] as? Int ?? 2
        bodyView.numberOfLines = maxBodyLines
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        
        let advertiserView = UILabel()
        advertiserView.translatesAutoresizingMaskIntoConstraints = false
        advertiserView.font = smallFont
        advertiserView.textColor = colorFromHex(customOptions["advertiserColor"] as? String) ?? UIColor.gray
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        
        let ratingView = UILabel()
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.font = smallFont
        ratingView.textColor = colorFromHex(customOptions["ratingColor"] as? String) ?? UIColor.systemYellow
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        
        let priceView = UILabel()
        priceView.translatesAutoresizingMaskIntoConstraints = false
        priceView.font = regularFont
        priceView.textColor = colorFromHex(customOptions["priceColor"] as? String) ?? UIColor.gray
        adView.addSubview(priceView)
        adView.priceView = priceView
        
        let actionButton = UIButton(type: .system)
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.titleLabel?.font = boldFont
        actionButton.setTitleColor(colorFromHex(customOptions["buttonTextColor"] as? String) ?? UIColor.white, for: .normal)
        let btnBgStr = customOptions["buttonBgColor"] as? String
        actionButton.backgroundColor = colorFromHex(btnBgStr) ?? UIColor.systemBlue
        let btnCorner = (customOptions["buttonCornerRadius"] as? Double) ?? 4.0
        actionButton.layer.cornerRadius = CGFloat(btnCorner)
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        
        // Disable touch interactions on elements that shouldn't steal clicks, let the adView handle it.
        iconView.isUserInteractionEnabled = false
        badgeView.isUserInteractionEnabled = false
        headlineView.isUserInteractionEnabled = false
        bodyView.isUserInteractionEnabled = false
        advertiserView.isUserInteractionEnabled = false
        ratingView.isUserInteractionEnabled = false
        
        let padding: CGFloat = 8.0
        
        let type = customOptions["nativeType"] as? String ?? "small1"
        
        let excludeAdvertiserAndRating = ["small5", "small6", "small7", "small8"].contains(type)
        if excludeAdvertiserAndRating {
            advertiserView.isHidden = true
            ratingView.isHidden = true
            adView.advertiserView = nil
            adView.starRatingView = nil
        }
        
        if type == "small4" {
            iconView.isHidden = true
            
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            priceView.setContentHuggingPriority(.required, for: .horizontal)
            priceView.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            if #available(iOS 11.0, *) {
                actionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                actionButton.layer.cornerRadius = CGFloat(bgCorner)
            }
            
            var constraints = [
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                
                badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding)
            ]
            
            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 4),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    ratingView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    priceView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingView.trailingAnchor, constant: 4),
                    priceView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
                    priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    
                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            
            NSLayoutConstraint.activate(constraints)
            
        } else if type == "small3" || type == "small6" {
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            if #available(iOS 11.0, *) {
                actionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                actionButton.layer.cornerRadius = CGFloat(bgCorner)
            }
            
            var constraints = [
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),
                
                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding)
            ]
            
            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 4),
                    advertiserView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    ratingView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    ratingView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            
            NSLayoutConstraint.activate(constraints)
            
        } else if type == "small7" {
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            if #available(iOS 11.0, *) {
                actionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                actionButton.layer.cornerRadius = CGFloat(bgCorner)
            }
            
            var constraints = [
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
                
                badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding)
            ]
            
            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 4),
                    advertiserView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    ratingView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    ratingView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            
            NSLayoutConstraint.activate(constraints)
            
        } else if type == "small2" || type == "small8" {
            // To prevent overlap/hidden issues, we must embed everything carefully.
            // Action button size
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            var constraints = [
                // CTA Action Button (Far Right, Vertically Centered with entire View)
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36),
                
                // Top Row: Badge -> Headline (Taking remaining horizontal space)
                badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                // Body Stack: Body
                bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4)
            ]
            
            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    // Bottom Stack: Advertiser/Rating
                    advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 4),
                    advertiserView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    ratingView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    ratingView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    // Extra boundary constraint for body if no advertiser is present
                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            
            NSLayoutConstraint.activate(constraints)
            
        } else {
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                iconView.topAnchor.constraint(greaterThanOrEqualTo: adView.topAnchor, constant: padding),
                iconView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),
                
                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),
                
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36)
            ]
            
            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 2),
                    advertiserView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
                    ratingView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                    ratingView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                    
                    // Additional boundary enforcement
                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }

            NSLayoutConstraint.activate(constraints)
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
        
        if type == "small2" || type == "small4" || type == "small7" || type == "small8" {
            iconView.isHidden = true
            adView.iconView = nil
        } else if let icon = nativeAd.icon {
            iconView.image = icon.image
        } else {
            iconView.isHidden = true
            adView.iconView = nil
        }
        
        adView.callToActionView?.isUserInteractionEnabled = false
        adView.nativeAd = nativeAd
        return adView
    }
    
    private func colorFromHex(_ hexStr: String?) -> UIColor? {
        guard let hex = hexStr, hex.hasPrefix("#") else { return nil }
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
        guard let family = family, !family.isEmpty else { return nil }
        
        // 1. Try if font is already available by PostScript Name
        if let font = UIFont(name: "\(family)-\(weight)", size: size) { return font }
        if let font = UIFont(name: family, size: size) { return font }
        
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
