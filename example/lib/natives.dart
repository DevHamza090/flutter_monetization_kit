import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

class NativesScreen extends StatefulWidget {
  const NativesScreen({super.key});

  @override
  State<NativesScreen> createState() => _NativesScreenState();
}

class _NativesScreenState extends State<NativesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Google Test IDs for Native Ads
  String get _testAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 21, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Ads Demo'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Small 1'),
            Tab(text: 'Small 2'),
            Tab(text: 'Small 3'),
            Tab(text: 'Small 4'),
            Tab(text: 'Small 5'),
            Tab(text: 'Small 6'),
            Tab(text: 'Small 7'),
            Tab(text: 'Small 8'),
            Tab(text: 'Medium 1'),
            Tab(text: 'Medium 2'),
            Tab(text: 'Medium 3'),
            Tab(text: 'Medium 4'),
            Tab(text: 'Medium 5'),
            Tab(text: 'Medium 6'),
            Tab(text: 'Large 1'),
            Tab(text: 'Large 2'),
            Tab(text: 'Large 3'),
            Tab(text: 'Large 4'),
            Tab(text: 'Large 5'),
            Tab(text: 'Large 6'),
            Tab(text: 'Custom Style'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNativeDemo(
            title: 'Native Ad - Small 1',
            screenRemote: true,
            type: NativeType.small1,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 2',
            type: NativeType.small2,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 3',
            type: NativeType.small3,
            screenRemote: false,
            style: const NativeAdStyle(maxBodyLines: 1),
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 4',
            type: NativeType.small4,
            screenRemote: false,
            style: const NativeAdStyle(
              maxBodyLines: 1,
              priceColor: Colors
                  .blue, // Explicitly assign a color to see if it triggers correctly natively
            ),
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 5',
            type: NativeType.small5,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 6',
            type: NativeType.small6,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 7',
            type: NativeType.small7,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Small 8',
            type: NativeType.small8,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 1',
            type: NativeType.medium1,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 2',
            type: NativeType.medium2,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 3',
            type: NativeType.medium3,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 4',
            type: NativeType.medium4,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 5',
            type: NativeType.medium5,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Medium 6',
            type: NativeType.medium6,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 1',
            type: NativeType.large1,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 2',
            type: NativeType.large2,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 3',
            type: NativeType.large3,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 4',
            type: NativeType.large4,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 5',
            type: NativeType.large5,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Large 6',
            type: NativeType.large6,
            screenRemote: false,
          ),
          _buildNativeDemo(
            title: 'Native Ad - Custom Dark Style',
            type: NativeType.small1,
            screenRemote: false,
            screenName: "custom",
            style: const NativeAdStyle(
              bgColor: Color(0xFF1E1E1E), // Dark Background
              headingColor: Colors.white,
              bodyColor: Colors.white70,
              advertiserColor: Colors.amberAccent,
              ratingColor: Colors.amber,
              ratingBgColor: Colors.white24,
              buttonBgColor: Colors.amber, // Amber CTA
              buttonTextColor: Colors.black,
              adTextBgColor: Colors.red,
              adTextColor: Colors.white,
              bgCorner: 12.0,
              adStrokeColor: Colors.white,
              buttonCornerRadius: 20.0,
              adTextBgCorner: 20.0,
              maxBodyLines: 1,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNativeDemo({
    required String title,
    required NativeType type,
    required bool screenRemote,
    String? screenName,
    NativeAdStyle style = const NativeAdStyle(),
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.amp_stories_rounded,
              size: 64,
              color: Colors.blue.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Below is the NativeWidget layout dynamically rendering the Ad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            // Wrap in a card/container to demonstrate layout bounds
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(style.bgCorner),
              ),
              child: NativeWidget(
                screenRemote: screenRemote,
                adUnit: _testAdUnitId,
                type: type,
                style: style,
                screenName: screenName,
                reloadAfterShow: true,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Example of manually triggering a reload with new adUnit
                setState(() {});
              },
              child: const Text('Refresh Ad'),
            ),
          ],
        ),
      ),
    );
  }
}
