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
        let maxBodyLines = customOptions["maxBodyLines"] as? Int ?? 2
        bodyView.numberOfLines = maxBodyLines

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
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            // Media Left | Right column: [Icon + Badge + Headline] / [Body] / [Full-width Button]
            var constraints = [NSLayoutConstraint]()

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            // Right column leading anchor (reused for body + button)
            let rightLeading = mediaView.trailingAnchor

            constraints.append(contentsOf: [
                // MediaView — full height, left 45%
                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
                mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
                mediaView.widthAnchor.constraint(equalTo: adView.widthAnchor, multiplier: 0.45),

                // Icon — top of right column, 56×56
                iconView.leadingAnchor.constraint(equalTo: rightLeading, constant: padding),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                // AD badge — right of icon, top-aligned
                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                // Headline — right of badge, max 2 lines
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                // Body — below heading text, right of icon
                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),

                // Button — full right-column width, pinned to bottom
                actionButton.leadingAnchor.constraint(equalTo: rightLeading, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
                actionButton.heightAnchor.constraint(equalToConstant: 44),

                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -6)
            ])

            // Visual Polish
            mediaView.layer.cornerRadius = 12.0
            mediaView.clipsToBounds = true
            iconView.layer.cornerRadius = 12.0
            iconView.clipsToBounds = true

            NSLayoutConstraint.activate(constraints)
        } else if type == "medium2" {
            // Right column: Media Right | Left column: [Icon + Badge + Headline] / [Body] / [Full-width Button]
            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            // Left column trailing anchor (reused for body + button)
            let leftTrailing = mediaView.leadingAnchor

            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                // MediaView — full height, right 45%, flush to trailing edge
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
                mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
                mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
                mediaView.widthAnchor.constraint(equalTo: adView.widthAnchor, multiplier: 0.45),

                // Icon — top of left column, 56×56
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                // AD badge — right of icon, top-aligned
                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                // Headline — right of badge, same row
                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: leftTrailing, constant: -padding),

                // Body — below heading text, right of icon
                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(equalTo: leftTrailing, constant: -padding),

                // Button — full left-column width, pinned to bottom with padding
                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: leftTrailing, constant: -padding),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
                actionButton.heightAnchor.constraint(equalToConstant: 44),

                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -6)
            ]

            // Visual Polish
            mediaView.layer.cornerRadius = 12.0
            mediaView.clipsToBounds = true
            iconView.layer.cornerRadius = 12.0
            iconView.clipsToBounds = true

            NSLayoutConstraint.activate(constraints)

        } else if type == "medium3" {
            // No Media, Full Button Bottom, 56dp Icon Left
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
                actionButton.heightAnchor.constraint(equalToConstant: 48),

                iconView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -12)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "medium4" {
            // No Media, Full Button Top, 56dp Icon Left
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                actionButton.heightAnchor.constraint(equalToConstant: 48),

                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                iconView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                iconView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -12)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "medium5" {
            // No Media, No Adv/Rating/Price, Full Button Bottom, 56dp Icon Left
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
                actionButton.heightAnchor.constraint(equalToConstant: 48),

                iconView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -12)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "medium6" {
            // No Media, No Adv/Rating/Price, Full Button Top, 56dp Icon Left
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
                actionButton.heightAnchor.constraint(equalToConstant: 48),

                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
                iconView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                iconView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -12)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "small2" || type == "small8" {
            // No Icon styles
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            if !excludeAdvertiserAndRating {
                adView.addSubview(advertiserView)
                adView.advertiserView = advertiserView
                adView.addSubview(ratingView)
                adView.starRatingView = ratingView
                adView.addSubview(priceView)
                adView.priceView = priceView
            }

            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

            var constraints = [
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36),

                badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4)
            ]
            bodyView.numberOfLines = 1

            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),

                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                    priceView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
                    priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            NSLayoutConstraint.activate(constraints)

        } else if type == "small3" || type == "small4" || type == "small5" || type == "small6" || type == "small7" {
            // Custom Horizontal CTA (Side-by-side with content)
            if type != "small7" {
                adView.addSubview(iconView)
                adView.iconView = iconView
            }
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            if !excludeAdvertiserAndRating {
                adView.addSubview(advertiserView)
                adView.advertiserView = advertiserView
                adView.addSubview(ratingView)
                adView.starRatingView = ratingView
            }

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
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
            ]

            let contentLeadingAnchor: NSLayoutXAxisAnchor
            if type == "small7" || type == "small6" || type == "small5" {
                contentLeadingAnchor = adView.leadingAnchor
            } else {
                constraints.append(contentsOf: [
                    iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                    iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                    iconView.widthAnchor.constraint(equalToConstant: 56),
                    iconView.heightAnchor.constraint(equalToConstant: 56)
                ])
                contentLeadingAnchor = iconView.trailingAnchor
            }

            // badgeView starts right after icon with a small gap; headline and body align to badge's leading
            constraints.append(contentsOf: [
                badgeView.leadingAnchor.constraint(equalTo: contentLeadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
                bodyView.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding)
            ])
            bodyView.numberOfLines = (type == "small4" || type == "small6") ? 2 : 1

            if excludeAdvertiserAndRating {
                constraints.append(bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding))
            } else {
                constraints.append(contentsOf: [
                    advertiserView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
                    advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),
                    advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),

                    ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                    ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                    bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
                ])
            }
            NSLayoutConstraint.activate(constraints)

        } else if type == "small1" {
            // Traditional Small1 / Default
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView

            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),
                advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36),

                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
            ]
            bodyView.numberOfLines = 1
            NSLayoutConstraint.activate(constraints)


        } else if type == "large1" {
            // Top: Icon + Text (Badge/Headline/Body/Adv/Stars/Price)
            // Middle: Action Button full width
            // Bottom: Large Media View
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 18)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 64),
                iconView.heightAnchor.constraint(equalToConstant: 64),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 10),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                priceView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingView.trailingAnchor, constant: 4),
                priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
                actionButton.topAnchor.constraint(greaterThanOrEqualTo: advertiserView.bottomAnchor, constant: padding),
                actionButton.heightAnchor.constraint(equalToConstant: 40),

                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: padding),
                mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "large2" {
            // Top: Icon + Text
            // Middle: Large Media View
            // Bottom: Action Button full width
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 18)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 64),
                iconView.heightAnchor.constraint(equalToConstant: 64),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 10),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                priceView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingView.trailingAnchor, constant: 4),
                priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: advertiserView.bottomAnchor, constant: padding),

                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: padding),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
                actionButton.heightAnchor.constraint(equalToConstant: 40)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "large3" {
            // Top: Large Media View
            // Bottom: Horizontal Stack (Icon, Text block in middle, Action Button right)
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            actionButton.setContentHuggingPriority(.required, for: .horizontal)

            var constraints = [
                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),

                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: padding),
                iconView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 10),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "large4" {
            // Top: Action Button full width
            // Middle: Icon + Text block
            // Bottom: Large Media View
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 18)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.topAnchor.constraint(equalTo: adView.topAnchor),
                actionButton.heightAnchor.constraint(equalToConstant: 40),

                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 64),
                iconView.heightAnchor.constraint(equalToConstant: 64),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),

                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: bodyView.bottomAnchor, constant: padding),
                mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "large5" {
            // Top: Icon Right, Text (Badge/Headline/Body/Adv/Stars/Price) Left
            // Middle: Large Media View
            // Bottom: Action Button full width
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 18)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            var constraints = [
                iconView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 64),
                iconView.heightAnchor.constraint(equalToConstant: 64),

                badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: iconView.leadingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 10),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                priceView.leadingAnchor.constraint(greaterThanOrEqualTo: ratingView.trailingAnchor, constant: 4),
                priceView.trailingAnchor.constraint(equalTo: iconView.leadingAnchor, constant: -padding),
                priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: advertiserView.bottomAnchor, constant: padding),

                actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: padding),
                actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
                actionButton.heightAnchor.constraint(equalToConstant: 40)
            ]
            NSLayoutConstraint.activate(constraints)

        } else if type == "large6" {
            // Top: Icon Left, Text Middle, Action Button Right
            // Bottom: Large Media View
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton
            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView
            adView.addSubview(priceView)
            adView.priceView = priceView

            let mediaView = MediaView()
            mediaView.translatesAutoresizingMaskIntoConstraints = false
            adView.addSubview(mediaView)
            adView.mediaView = mediaView

            headlineView.font = UIFont.boldSystemFont(ofSize: 16)
            headlineView.numberOfLines = 1
            bodyView.numberOfLines = 2

            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            actionButton.setContentHuggingPriority(.required, for: .horizontal)

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding + 20),
                iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 10),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor, constant: 12),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 40),

                mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
                mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
            ]
            NSLayoutConstraint.activate(constraints)

        } else {
            // Default / Fallback (Safe explicit registration)
            adView.addSubview(iconView)
            adView.iconView = iconView
            adView.addSubview(badgeView)
            adView.addSubview(headlineView)
            adView.headlineView = headlineView
            adView.addSubview(bodyView)
            adView.bodyView = bodyView
            adView.addSubview(actionButton)
            adView.callToActionView = actionButton

            adView.addSubview(advertiserView)
            adView.advertiserView = advertiserView
            adView.addSubview(ratingView)
            adView.starRatingView = ratingView

            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)

            var constraints = [
                iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
                iconView.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 56),
                iconView.heightAnchor.constraint(equalToConstant: 56),

                badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: padding),
                badgeView.widthAnchor.constraint(equalToConstant: 24),
                badgeView.heightAnchor.constraint(equalToConstant: 16),

                headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
                headlineView.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
                headlineView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
                bodyView.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -padding),

                advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
                advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 2),
                advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),

                ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
                ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),

                actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
                actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
                actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
                actionButton.heightAnchor.constraint(equalToConstant: 36),

                bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding)
            ]
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
