import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/monetization_kit.dart';
import 'package:flutter_monetization_kit_example/ads_demo_selection.dart';

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
  bool _isAdsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAdsAndConsent();
  }

  Future<void> _initAdsAndConsent() async {
    // 1. Gather Consent
    MonetizationKit.instance.consentManager.gatherConsent(
      testIdentifiers: ["B7DA4CA04608DA8F16C9261B79325934"],
      onConsentGatheringCompleteListener: (error) async {
        if (error != null) {
          debugPrint('Consent Gathering Error: $error');
        }

        // 2. Initialize the monetization kit after consent gathering is complete
        await MonetizationKit.instance.initialize(
          isDebug: true, // Use test IDs
          enableBannerAds: true,
          navigatorKey: navigatorKey,
        );

        // 3. Setup App Open Ads Observer
        // final observer = AppOpenObserver(
        //   adUnitId: AdUtils.testId(AdType.appOpen),
        // );
        // WidgetsBinding.instance.addObserver(observer);

        // 4. Update UI to show the main app
        if (mounted) {
          setState(() {
            _isAdsInitialized = true;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Monetization Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: _isAdsInitialized
          ? const AdsDemoSelection()
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
    );
  }
}
