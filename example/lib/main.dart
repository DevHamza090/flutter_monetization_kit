import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';
import 'package:flutter_monetization_kit_example/ads_demo_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the monetization kit
  await EasyAds.instance.initialize(
    isDebug: true, // Use test IDs
    enableBannerAds: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monetization Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AdsDemoSelection(),
    );
  }
}
