class AdRegistry {
  AdRegistry._();
  static final AdRegistry instance = AdRegistry._();

  // Stores any loaded ad: Key is AdUnitId, Value is the Ad object (InterstitialAd, RewardedAd, etc.)
  final Map<String, Object> _loadedAds = {};

  // Tracks loading status for ANY ad type
  final Set<String> _loadingIds = {};

  // Tracks if a full screen ad is currently being shown
  bool isFullScreenAdShowing = false;

  // Tracks the last time a full screen ad was dismissed
  DateTime? lastDismissedTime;

  // Tracks if an ad was clicked recently to suppress App Open ad on resume
  bool wasAdClickedRecently = false;

  bool isAdLoading(String id) => _loadingIds.contains(id);
  bool isAdReady(String id) => _loadedAds.containsKey(id);

  void markLoading(String id) => _loadingIds.add(id);

  void setAd(String id, Object ad) {
    _loadedAds[id] = ad;
    _loadingIds.remove(id);
  }

  // Use Generics to get the right ad type back
  T? getAd<T>(String id) {
    final ad = _loadedAds[id];
    return ad is T ? ad : null;
  }

  void removeAd(String id) {
    // You would add disposal logic here based on type
    _loadedAds.remove(id);
  }
}
