import Foundation
import UIKit
import GoogleMobileAds

// MARK: - Native Ad Layout Styles
// Each function builds and activates Auto Layout constraints for one ad template type.
// Called from buildNativeAdView(_:customOptions:) in GoogleNativeAdPlatformView.

extension GoogleNativeAdPlatformView {

    // MARK: Small1 — Icon Left | Badge+Headline+Body | Side Button
    func applyLayoutSmall1(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        bodyView.numberOfLines = 1
        NSLayoutConstraint.activate([
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
            bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
            advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),
            advertiserView.topAnchor.constraint(greaterThanOrEqualTo: adView.topAnchor, constant: padding),
            advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: Small2 / Small8 — No Icon, Side Button, Optional Advertiser Row
    func applyLayoutSmall2_8(
        adView: NativeAdView, badgeView: UILabel, headlineView: UILabel,
        bodyView: UILabel, advertiserView: UILabel, ratingView: UILabel,
        priceView: UILabel, actionButton: UIButton, padding: CGFloat,
        excludeAdvertiserAndRating: Bool
    ) {
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        if !excludeAdvertiserAndRating {
            adView.addSubview(advertiserView); adView.advertiserView = advertiserView
            adView.addSubview(ratingView); adView.starRatingView = ratingView
            adView.addSubview(priceView); adView.priceView = priceView
        }
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        bodyView.numberOfLines = 1
        var constraints: [NSLayoutConstraint] = [
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
    }

    // MARK: Small3–7 — Optional Icon, Full-Height Side Button
    func applyLayoutSmall3_7(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, actionButton: UIButton, padding: CGFloat,
        type: String, bgCorner: CGFloat, excludeAdvertiserAndRating: Bool
    ) {
        if type != "small7" { adView.addSubview(iconView); adView.iconView = iconView }
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        if !excludeAdvertiserAndRating {
            adView.addSubview(advertiserView); adView.advertiserView = advertiserView
            adView.addSubview(ratingView); adView.starRatingView = ratingView
        }
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        if #available(iOS 11.0, *) {
            actionButton.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            actionButton.layer.cornerRadius = CGFloat(bgCorner)
        }
        var constraints: [NSLayoutConstraint] = [
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
        bodyView.numberOfLines = (type == "small4" || type == "small6") ? 2 : 1
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
    }


    // MARK: Medium1 — Media Left | Icon+Badge+Text+Button Right
    func applyLayoutMedium1(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        mediaView.layer.cornerRadius = 06.0; mediaView.clipsToBounds = true
        iconView.layer.cornerRadius = 06.0; iconView.clipsToBounds = true
        let rightLeading = mediaView.trailingAnchor
        NSLayoutConstraint.activate([
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
            mediaView.widthAnchor.constraint(equalTo: adView.widthAnchor, multiplier: 0.45),
            iconView.leadingAnchor.constraint(equalTo: rightLeading, constant: padding),
            iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
            headlineView.trailingAnchor.constraint(lessThanOrEqualTo: adView.trailingAnchor, constant: -padding),
            bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: rightLeading, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            bodyView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -6)
        ])
    }

    // MARK: Medium2 — Icon+Badge+Text+Button Left | Media Right
    func applyLayoutMedium2(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        mediaView.layer.cornerRadius = 06.0; mediaView.clipsToBounds = true
        iconView.layer.cornerRadius = 06.0; iconView.clipsToBounds = true
        let leftTrailing = mediaView.leadingAnchor
        NSLayoutConstraint.activate([
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
            mediaView.widthAnchor.constraint(equalTo: adView.widthAnchor, multiplier: 0.45),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
            iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: iconView.topAnchor),
            headlineView.trailingAnchor.constraint(lessThanOrEqualTo: leftTrailing, constant: -padding),
            bodyView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
            bodyView.trailingAnchor.constraint(equalTo: leftTrailing, constant: -padding),
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: leftTrailing, constant: -padding),
            actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
            bodyView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -6)
        ])
    }

    // MARK: Medium3 — No Media, Button Bottom, Icon Left, Advertiser Row
    func applyLayoutMedium3(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        NSLayoutConstraint.activate([
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
            advertiserView.topAnchor.constraint(greaterThanOrEqualTo: adView.topAnchor, constant: padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
            actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
            actionButton.heightAnchor.constraint(equalToConstant: 48),
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: actionButton.topAnchor, constant: -12)
        ])
    }

    // MARK: Medium4 — No Media, Button Top, Icon Left, Advertiser Row
    func applyLayoutMedium4(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        NSLayoutConstraint.activate([
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
            advertiserView.topAnchor.constraint(greaterThanOrEqualTo: adView.topAnchor, constant: padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            iconView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: Medium5 — No Media, No Advertiser, Button Bottom, Icon Left
    func applyLayoutMedium5(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        NSLayoutConstraint.activate([
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
        ])
    }

    // MARK: Medium6 — No Media, No Advertiser, Button Top, Icon Left
    func applyLayoutMedium6(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 2
        NSLayoutConstraint.activate([
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
        ])
    }

} // end extension (Small + Medium layouts)

// MARK: - Large Native Ad Layout Styles
extension GoogleNativeAdPlatformView {

    // MARK: Large1 — Icon+Text Top | Media Middle | Button Bottom
    func applyLayoutLarge1(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 18)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        NSLayoutConstraint.activate([
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
        ])
    }

    // MARK: Large2 — Button Top | Icon+Text Middle | Media Bottom
    func applyLayoutLarge2(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 18)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
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
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
        ])
    }

    // MARK: Large3 — Icon+Text Top | Button Middle | Media Bottom
    func applyLayoutLarge3(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 18)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        NSLayoutConstraint.activate([
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
        ])
    }

    // MARK: Large4 — Button Top | Icon Right+Text Left Middle | Media Bottom
    func applyLayoutLarge4(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 18)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: padding),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            iconView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            iconView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: padding),
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
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
        ])
    }

    // MARK: Large5 — Media Top | Icon+Text+Button Bottom Row
    func applyLayoutLarge5(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
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
            advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    // MARK: Large6 — Icon Left+Text Middle+Button Right Top | Media Bottom
    func applyLayoutLarge6(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        adView.addSubview(priceView); adView.priceView = priceView
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(mediaView); adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1; bodyView.numberOfLines = 1
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
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
            advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: mediaView.topAnchor, constant: -padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: actionButton.leadingAnchor, constant: -padding),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 40),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: padding),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: padding),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -padding)
        ])
    }

    // MARK: Default Fallback — Small1-style with Advertiser
    func applyLayoutDefault(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        adView.addSubview(iconView); adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView); adView.headlineView = headlineView
        adView.addSubview(bodyView); adView.bodyView = bodyView
        adView.addSubview(actionButton); adView.callToActionView = actionButton
        adView.addSubview(advertiserView); adView.advertiserView = advertiserView
        adView.addSubview(ratingView); adView.starRatingView = ratingView
        actionButton.setContentHuggingPriority(.required, for: .horizontal)
        actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
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
            bodyView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
            advertiserView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: padding),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 2),
            advertiserView.bottomAnchor.constraint(lessThanOrEqualTo: adView.bottomAnchor, constant: -padding),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -padding),
            actionButton.centerYAnchor.constraint(equalTo: adView.centerYAnchor),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

} // end extension (Large layouts)

// MARK: - Fullscreen Native Ad Layout Styles (full width × height, MediaView for video)
extension GoogleNativeAdPlatformView {

    /// Fullscreen1 — Top metadata row | flexible MediaView | bottom CTA (matches Android native_ad_fullscreen_1).
    func applyLayoutFullscreen1(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
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
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        adView.addSubview(priceView)
        adView.priceView = priceView
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        headlineView.font = UIFont.boldSystemFont(ofSize: 17)
        headlineView.numberOfLines = 2
        bodyView.numberOfLines = 2
        let p = max(padding, 12)
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            iconView.topAnchor.constraint(equalTo: adView.topAnchor, constant: p),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: badgeView.topAnchor),
            headlineView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            bodyView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            advertiserView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: 12),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: advertiserView.bottomAnchor, constant: 12),
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            actionButton.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 12),
            actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -p),
            actionButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    /// Fullscreen2 — CTA top | metadata | MediaView fills remainder.
    func applyLayoutFullscreen2(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        adView.addSubview(iconView)
        adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        adView.addSubview(priceView)
        adView.priceView = priceView
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        headlineView.font = UIFont.boldSystemFont(ofSize: 17)
        headlineView.numberOfLines = 2
        bodyView.numberOfLines = 2
        let p = max(padding, 12)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: p),
            actionButton.heightAnchor.constraint(equalToConstant: 52),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            iconView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: badgeView.topAnchor),
            headlineView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            bodyView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            advertiserView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 6),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: 12),
            mediaView.topAnchor.constraint(greaterThanOrEqualTo: advertiserView.bottomAnchor, constant: 12),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -p)
        ])
    }

    /// Fullscreen3 — Full-bleed MediaView; badge top; bottom overlay stack (icon, headline, body, meta, CTA).
    func applyLayoutFullscreen3(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        mediaView.layer.cornerRadius = 0
        mediaView.clipsToBounds = true
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        adView.addSubview(badgeView)
        adView.addSubview(iconView)
        adView.iconView = iconView
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        adView.addSubview(priceView)
        adView.priceView = priceView
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        headlineView.font = UIFont.boldSystemFont(ofSize: 18)
        headlineView.textColor = .white
        headlineView.numberOfLines = 2
        bodyView.font = UIFont.systemFont(ofSize: 13)
        bodyView.textColor = UIColor(white: 0.95, alpha: 1)
        bodyView.numberOfLines = 2
        advertiserView.textColor = UIColor(white: 0.8, alpha: 1)
        priceView.textColor = UIColor(white: 0.95, alpha: 1)
        let p = max(padding, 12)
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: adView.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
            badgeView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            badgeView.topAnchor.constraint(equalTo: adView.topAnchor, constant: p),
            badgeView.widthAnchor.constraint(equalToConstant: 28),
            badgeView.heightAnchor.constraint(equalToConstant: 18),
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            actionButton.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -p),
            actionButton.heightAnchor.constraint(equalToConstant: 52),
            advertiserView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            advertiserView.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -8),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 6),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            bodyView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            bodyView.bottomAnchor.constraint(equalTo: advertiserView.topAnchor, constant: -8),
            headlineView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            headlineView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            headlineView.bottomAnchor.constraint(equalTo: bodyView.topAnchor, constant: -4),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            iconView.bottomAnchor.constraint(equalTo: headlineView.topAnchor, constant: -8),
            iconView.widthAnchor.constraint(equalToConstant: 48),
            iconView.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    /// Fullscreen4 — Top half MediaView; bottom half metadata + CTA.
    func applyLayoutFullscreen4(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        let topPane = UILayoutGuide()
        let bottomPane = UILayoutGuide()
        adView.addLayoutGuide(topPane)
        adView.addLayoutGuide(bottomPane)
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
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        adView.addSubview(priceView)
        adView.priceView = priceView
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        headlineView.font = UIFont.boldSystemFont(ofSize: 17)
        headlineView.numberOfLines = 2
        bodyView.numberOfLines = 3
        let p = max(padding, 12)
        NSLayoutConstraint.activate([
            topPane.topAnchor.constraint(equalTo: adView.topAnchor),
            topPane.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            topPane.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            topPane.heightAnchor.constraint(equalTo: adView.heightAnchor, multiplier: 0.5),
            bottomPane.topAnchor.constraint(equalTo: topPane.bottomAnchor),
            bottomPane.leadingAnchor.constraint(equalTo: adView.leadingAnchor),
            bottomPane.trailingAnchor.constraint(equalTo: adView.trailingAnchor),
            bottomPane.bottomAnchor.constraint(equalTo: adView.bottomAnchor),
            mediaView.topAnchor.constraint(equalTo: topPane.topAnchor),
            mediaView.leadingAnchor.constraint(equalTo: topPane.leadingAnchor),
            mediaView.trailingAnchor.constraint(equalTo: topPane.trailingAnchor),
            mediaView.bottomAnchor.constraint(equalTo: topPane.bottomAnchor),
            iconView.leadingAnchor.constraint(equalTo: bottomPane.leadingAnchor, constant: p),
            iconView.topAnchor.constraint(equalTo: bottomPane.topAnchor, constant: p),
            iconView.widthAnchor.constraint(equalToConstant: 56),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: badgeView.topAnchor),
            headlineView.trailingAnchor.constraint(equalTo: bottomPane.trailingAnchor, constant: -p),
            bodyView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 4),
            bodyView.trailingAnchor.constraint(equalTo: bottomPane.trailingAnchor, constant: -p),
            advertiserView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 8),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: bottomPane.trailingAnchor, constant: -p),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            actionButton.leadingAnchor.constraint(equalTo: bottomPane.leadingAnchor, constant: p),
            actionButton.trailingAnchor.constraint(equalTo: bottomPane.trailingAnchor, constant: -p),
            actionButton.topAnchor.constraint(equalTo: advertiserView.bottomAnchor, constant: 12),
            actionButton.bottomAnchor.constraint(equalTo: bottomPane.bottomAnchor, constant: -p),
            actionButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }

    /// Fullscreen5 — CTA top | flexible MediaView | bottom icon + text column.
    func applyLayoutFullscreen5(
        adView: NativeAdView, iconView: UIImageView, badgeView: UILabel,
        headlineView: UILabel, bodyView: UILabel, advertiserView: UILabel,
        ratingView: UILabel, priceView: UILabel, actionButton: UIButton, padding: CGFloat
    ) {
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        adView.addSubview(actionButton)
        adView.callToActionView = actionButton
        adView.addSubview(mediaView)
        adView.mediaView = mediaView
        adView.addSubview(iconView)
        adView.iconView = iconView
        adView.addSubview(badgeView)
        adView.addSubview(headlineView)
        adView.headlineView = headlineView
        adView.addSubview(bodyView)
        adView.bodyView = bodyView
        adView.addSubview(advertiserView)
        adView.advertiserView = advertiserView
        adView.addSubview(ratingView)
        adView.starRatingView = ratingView
        adView.addSubview(priceView)
        adView.priceView = priceView
        headlineView.font = UIFont.boldSystemFont(ofSize: 16)
        headlineView.numberOfLines = 1
        bodyView.numberOfLines = 2
        let p = max(padding, 12)
        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            actionButton.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            actionButton.topAnchor.constraint(equalTo: adView.topAnchor, constant: p),
            actionButton.heightAnchor.constraint(equalToConstant: 52),
            iconView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            iconView.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -p),
            iconView.widthAnchor.constraint(equalToConstant: 52),
            iconView.heightAnchor.constraint(equalToConstant: 52),
            badgeView.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
            badgeView.topAnchor.constraint(equalTo: iconView.topAnchor, constant: 2),
            badgeView.widthAnchor.constraint(equalToConstant: 24),
            badgeView.heightAnchor.constraint(equalToConstant: 16),
            headlineView.leadingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: 4),
            headlineView.topAnchor.constraint(equalTo: badgeView.topAnchor),
            headlineView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            bodyView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            bodyView.topAnchor.constraint(equalTo: headlineView.bottomAnchor, constant: 2),
            bodyView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            advertiserView.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor),
            advertiserView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 4),
            ratingView.leadingAnchor.constraint(equalTo: advertiserView.trailingAnchor, constant: 4),
            ratingView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            priceView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            priceView.centerYAnchor.constraint(equalTo: advertiserView.centerYAnchor),
            mediaView.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: p),
            mediaView.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -p),
            mediaView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 12),
            mediaView.bottomAnchor.constraint(equalTo: iconView.topAnchor, constant: -12)
        ])
    }
}

