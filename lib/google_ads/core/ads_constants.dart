import 'dart:io';


class AdConstants {
  // Private constructor to prevent instantiation
  AdConstants._();

  /// How long to wait before trying to reload a failed ad (Initial)
  static const Duration initialRetryDelay = Duration(seconds: 30);

  /// Maximum number of retries before giving up for a specific screen
  static const int maxRetryAttempts = 3;

  /// The timeout duration for an ad request
  static const Duration adRequestTimeout = Duration(seconds: 15);

  /// --- LOGGING MESSAGES ---
  static const String prefix = "[EasyAds]";

  // --- Static Error Messages ---
  static const String errorNoInternet = "$prefix ❌ No internet connection. Ad load cancelled.";
  static const String errorPremiumUser = "$prefix 💎 User is Premium. Ads are disabled.";
  static const String msgAdLoading = "$prefix ⏳ Ad is already loading. Skipping duplicate request.";
}