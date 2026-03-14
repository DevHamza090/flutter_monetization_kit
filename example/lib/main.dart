import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';
import 'package:flutter_monetization_kit_example/ads_demo_selection.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the monetization kit
  await EasyAds.instance.initialize(
    isDebug: true, // Use test IDs
    enableBannerAds: true,
    navigatorKey: navigatorKey,
  );

  final observer = AppOpenObserver(
    adUnitId: AdUtils.testId(AdType.appOpen),
  );
  WidgetsBinding.instance.addObserver(observer);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Monetization Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AdsDemoSelection(),
    );
  }
}
