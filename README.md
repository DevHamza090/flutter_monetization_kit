# Flutter Monetization Kit 🚀

A powerful, unified, and easy-to-use Flutter plugin designed to handle **Google Mobile Ads** efficiently. It simplifies the setup and management of ads, handles User Messaging Platform (UMP) consent (for GDPR compliance), and provides robust management for Interstitial, Rewarded, App Open, Banner, and Native ads dynamically.

[![Pub Version](https://img.shields.io/pub/v/flutter_monetization_kit.svg)](https://pub.dev/packages/flutter_monetization_kit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

---

## ✨ Features

### 🟢 Google Mobile Ads
- **Banner Ads:** Readily accessible `BannerWidget`.
- **Interstitial Ads:** Manage with automatic intervals and caching.
- **Rewarded Ads:** Incentivize users simply.
- **Rewarded Interstitial Ads:** Hybrid rewarded experiences.
- **App Open Ads:** Hook into app lifecycle easily with `AppOpenObserver`.
- **Native Ads:** Highly customizable Native ad UI.
- **Consent Management (UMP):** Fully GDPR compliant consent gathering.
- **Premium Status Management:** Toggle ads off globally for premium users effortlessly.

---

## 🚀 Getting Started

### 1. Installation

Add the plugin to your `pubspec.yaml`:
```yaml
dependencies:
  flutter_monetization_kit: ^0.0.1
```

### 2. Platform Setup

#### Android
Update your `AndroidManifest.xml` (located at `android/app/src/main/AndroidManifest.xml`) with your AdMob App ID:

```xml
<manifest>
    <application>
        <!-- Sample AdMob App ID: ca-app-pub-3940256099942544~3347511713 -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="YOUR_ADMOB_APP_ID"/>
    </application>
</manifest>
```

#### iOS
Update your `Info.plist` (located at `ios/Runner/Info.plist`) with your AdMob App ID, the ATT usage description, and `SKAdNetworkItems`:

```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_ADMOB_APP_ID</string>
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <!-- Add other network IDs here -->
</array>
```

To request App Tracking Transparency (ATT) authorization on iOS 14+, you can use the built-in tracker:

```dart
import 'package:flutter_monetization_kit/monetization_kit.dart';

final status = await AppTrackingTransparency.requestTrackingAuthorization();
if (status == AppTrackingStatus.authorized) {
  print('Tracking authorized on iOS');
}
```

### 3. Initialization & Consent (GDPR)

It is crucial to request user consent via the UMP SDK before initializing the ads SDK. You can do this at the very beginning of your app (e.g., inside the `initState` of your main widget or splash screen).

```dart
import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initMonetization();
  }

  Future<void> _initMonetization() async {
    // 1. Gather User Consent
    MonetizationKit.instance.consentManager.gatherConsent(
      testIdentifiers: ['YOUR_TEST_DEVICE_ID'], // Optional: For testing in EEA
      onConsentGatheringCompleteListener: (error) async {
        if (error != null) {
          debugPrint('Consent Error: $error');
        }

        // 2. Initialize the Monetization Kit
        await MonetizationKit.instance.initialize(
          isDebug: true, // Set to false in production to use real IDs
          enableBannerAds: true,
          navigatorKey: navigatorKey,
        );

        // 3. Register App Open Ads Observer (Optional)
        final observer = AppOpenObserver(
          androidAdUnit: AdUtils.testId(AdType.appOpen),
          iosAdUnit: AdUtils.testId(AdType.appOpen),
        );
        WidgetsBinding.instance.addObserver(observer);
        
        // UI is ready to update
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const HomeScreen(),
    );
  }
}
```

---

## 💻 Usage Code Examples

All accesses to ads are neatly grouped under the `MonetizationKit.instance` singleton.

The SDK supports three distinct patterns for full-screen ads:
1. **Preload (`load`)**: Fetch the ad in advance without showing it.
2. **Show (`show`)**: Display a previously preloaded ad instantly.
3. **Load & Show (`loadAndShow`)**: A convenience method that handles both loading and showing in one go.

💡 **Universal Ad Caching:** The `screenName` parameter in `load()` and `show()` methods is entirely **optional**. If you do not pass a `screenName`, the ad is loaded and cached **universally** and can be shown from anywhere in your app!

### 1. Interstitial Ads

Pre-load and show interstitial ads. `MonetizationKit` handles automatic loading and interval tracking.

```dart
// Preload the ad
MonetizationKit.instance.interstitial.load(
  androidAdUnit: 'YOUR_ANDROID_AD_UNIT_ID', 
  iosAdUnit: 'YOUR_IOS_AD_UNIT_ID',
  screenName: 'home_screen',
);

// Show the ad
MonetizationKit.instance.interstitial.show(
  context: context,
  screenName: 'home_screen',
  onAdDismissed: () {
    print("Ad Dismissed - Navigate to next screen");
  },
);

// Load and show in one go
MonetizationKit.instance.interstitial.loadAndShow(
  context: context,
  screenName: 'home_screen',
);
```

### 2. Rewarded Ads

Provide value to users in exchange for watching an ad.

```dart
MonetizationKit.instance.rewarded.load(
  androidAdUnit: 'YOUR_ANDROID_AD_UNIT_ID',
  iosAdUnit: 'YOUR_IOS_AD_UNIT_ID',
  screenName: 'store_screen',
);

MonetizationKit.instance.rewarded.show(
  context: context,
  screenName: 'store_screen',
  onUserEarnedReward: (ad, reward) {
    print("User earned ${reward.amount} ${reward.type}");
  },
  onAdDismissed: () {
    print("Ad was closed");
  },
);

// Load and show in one go
MonetizationKit.instance.rewarded.loadAndShow(
  context: context,
  screenName: 'store_screen',
);
```

### 3. Rewarded Interstitial Ads

A hybrid ad type that provides a reward without the "choice" to skip, typically used for high-value rewards.

```dart
MonetizationKit.instance.rewardedInterstitial.load(
  androidAdUnit: 'YOUR_ANDROID_AD_UNIT_ID',
  iosAdUnit: 'YOUR_IOS_AD_UNIT_ID',
  screenName: 'game_over',
);

MonetizationKit.instance.rewardedInterstitial.show(
  context: context,
  screenName: 'game_over',
  onUserEarnedReward: (ad, reward) {
    print("User rewarded");
  },
);

// Load and show in one go
MonetizationKit.instance.rewardedInterstitial.loadAndShow(
  context: context,
  screenName: 'game_over',
);
```

### 4. App Open Ads

Handled via the `AppOpenObserver`. Whenever the user resumes the app, the observer dynamically shows the pre-loaded ad. It's configured automatically during initialization.

```dart
// Pause App Open showing manually if needed
MonetizationKit.instance.setAppOpenOnResume(false);

// Manually show if preloaded
MonetizationKit.instance.appOpen.show(
  context: context,
  screenRemote: true,
);

// Load and show in one go
MonetizationKit.instance.appOpen.loadAndShow(
  context: context,
  screenRemote: true,
);
```

### 5. Custom Loading UI

All full-screen ads (Interstitial, Rewarded, App Open) support a `customLoadingWidget` parameter. This allows you to show your own professional loading screen while the ad is preparing to show.

```dart
MonetizationKit.instance.interstitial.loadAndShow(
  context: context,
  screenRemote: true,
  customLoadingWidget: MyCustomLoadingScreen(),
  fullScreenDialog: true, // Whether the dialog should be full-screen
);
```

### 6. Banner Ads

Using the provided `BannerWidget` simplifies rendering standard banner ads.

```dart
import 'package:flutter_monetization_kit/monetization_kit.dart';

Container(
  child: BannerAdWidget(
    androidAdUnit: 'YOUR_ANDROID_AD_UNIT_ID',
    iosAdUnit: 'YOUR_IOS_AD_UNIT_ID',
    type: BannerType.standard, // standard, largeBanner, rectangleBanner, adaptiveBanner
    screenName: 'dashboard',
  ),
);
```

### 5. Native Ads

Using the provided `NativeWidget` to render deeply integrated custom UI components. 

```dart
// First load the native ad configuration
MonetizationKit.instance.native.load(
  androidAdUnit: 'YOUR_ANDROID_AD_UNIT_ID',
  iosAdUnit: 'YOUR_IOS_AD_UNIT_ID',
  screenName: 'feed_screen',
);

// Then render it anywhere in the tree
NativeWidget(
  screenName: 'feed_screen',
  factoryId: 'mediumFactory', // Factory ID registered in your native Android/iOS platform code
  height: 300,
);
```

### 6. Premium Status Control

Have premium users? With one line, you can disable all ad logs across the entire SDK.

```dart
// Tell the SDK the user is premium, all ad loading/showing will be bypassed.
await MonetizationKit.instance.setPremium(true); 
```

### 7. Google Consent Privacy Options (GDPR)

In order to comply with GDPR policies, users must be able to change their consent statuses at any time.

```dart
final isRequired = await MonetizationKit.instance.consentManager.isPrivacyOptionsRequired();
if (isRequired) {
  MonetizationKit.instance.consentManager.showPrivacyOptionsForm((error) {
    if (error != null) {
      print('Failed to show privacy options: $error');
    }
  });
}
```

---

## 🤝 Contributions
Feel free to open issues and pull requests to help improve this plugin. When creating PRs, please ensure that you pass formatting and analyzer checks.

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
