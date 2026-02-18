import Flutter
import UIKit
import GoogleMobileAds
import google_mobile_ads

class GoogleNativeAdFactory: NSObject, FLTNativeAdFactory {
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]?) -> GADNativeAdView? {
        let designId = customOptions?["designId"] as? String ?? "native1"
        
        let nib = UINib(nibName: designId, bundle: nil)
        guard let nibViews = nib.instantiate(withOwner: nil, options: nil) as? [UIView],
              let nativeAdView = nibViews.first as? GADNativeAdView else {
            return nil
        }
        
        applyColors(nativeAdView, colors: customOptions)
        bindAd(nativeAdView, nativeAd: nativeAd)
        
        return nativeAdView
    }

    private func applyColors(_ nativeAdView: GADNativeAdView, colors: [AnyHashable: Any]?) {
        guard let colors = colors else { return }
        
        if let bgColorHex = colors["backgroundColor"] as? String {
            nativeAdView.backgroundColor = UIColor(hex: bgColorHex)
        }
        
        if let buttonColorHex = colors["buttonColor"] as? String {
            (nativeAdView.callToActionView as? UIButton)?.backgroundColor = UIColor(hex: buttonColorHex)
        }
        
        if let textColorHex = colors["textColor"] as? String {
            (nativeAdView.headlineView as? UILabel)?.textColor = UIColor(hex: textColorHex)
        }
    }

    private func bindAd(_ nativeAdView: GADNativeAdView, nativeAd: GADNativeAd) {
        nativeAdView.nativeAd = nativeAd
        
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
    }
}

extension UIColor {
    convenience init?(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercaseString
        if cString.hasPrefix("#") { cString.removeAt(cString.startIndex) }
        if cString.count != 8 { return nil }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x000000FF) / 255.0,
            alpha: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0
        )
    }
}
