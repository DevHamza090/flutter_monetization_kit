/// Defines the different banner formats supported by the package
sealed class BannerType {
  const BannerType();

  static const BannerType standard = StandardBanner();
  static const BannerType adaptive = AdaptiveBanner();
  static const BannerType rectangle = RectangleBanner();
  static const BannerType large = LargeBanner();
}

class StandardBanner extends BannerType {
  const StandardBanner();
}

class AdaptiveBanner extends BannerType {
  const AdaptiveBanner();
}

class RectangleBanner extends BannerType {
  const RectangleBanner();
}

class LargeBanner extends BannerType {
  const LargeBanner();
}

/// For Collapsible Banners (Top or Bottom)
class CollapsibleBanner extends BannerType {
  final bool isTop;
  const CollapsibleBanner({this.isTop = false});
}

/// For Custom Height only
class CustomHeightBanner extends BannerType {
  final int height;
  const CustomHeightBanner(this.height);
}

/// For Custom Height and Width
class CustomSizeBanner extends BannerType {
  final int width;
  final int height;
  const CustomSizeBanner(this.width, this.height);
}
