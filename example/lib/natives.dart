import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

class NativesScreen extends StatefulWidget {
  const NativesScreen({Key? key}) : super(key: key);

  @override
  State<NativesScreen> createState() => _NativesScreenState();
}

class _NativesScreenState extends State<NativesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String _adUnitId = AdUtils.testId(AdType.native);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  NativeType _getNativeType(int index) {
    switch (index) {
      case 0:
        return NativeType.native1;
      case 1:
        return NativeType.native2;
      case 2:
        return NativeType.native3;
      case 3:
        return NativeType.native5;
      case 4:
        return NativeType.native10;
      default:
        return NativeType.native1;
    }
  }

  void _loadAd(String screenName, NativeType design) {
    NativeAdManager().loadAd(
      adUnitId: _adUnitId,
      screenName: screenName,
      designId: design.name,
      callbacks: NativeAdCallbacks(
        onAdLoaded: (ad) {
          debugPrint('Native Ad Loaded for $screenName');
          if (mounted) setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native Ad Failed for $screenName: ${error.message}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Ads Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Small (N1)'),
            Tab(text: 'Small (N2)'),
            Tab(text: 'Large (N3)'),
            Tab(text: 'Medium (N5)'),
            Tab(text: 'Advance (N10)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNativeDemo('native1', NativeType.native1),
          _buildNativeDemo('native2', NativeType.native2),
          _buildNativeDemo('native3', NativeType.native3, height: 350),
          _buildNativeDemo('native5', NativeType.native5, height: 250),
          _buildNativeDemo('native10', NativeType.native10, height: 300),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final type = _getNativeType(_tabController.index);
          _loadAd('tab_${type.name}', type);
        },
        label: const Text('Preload This Design'),
        icon: const Icon(Icons.download),
      ),
    );
  }

  Widget _buildNativeDemo(String id, NativeType design, {double height = 150}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Smart Loading - $id'),
          const Text(
            'Each design can be preloaded independently. '
            'The shimmer will adapt to the layout of the chosen design.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          NativeAdWidget(
            key: ValueKey('native_$id'),
            adUnitId: _adUnitId,
            screenName: 'tab_$id',
            designId: design,
            height: height,
            style: NativeAdStyle(
              buttonBgColor: Colors.blueAccent,
              headingColor: Colors.black,
              bgColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Usage Info:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Design ID: ${design.name}\n'
              'Ad Unit: $_adUnitId\n'
              'Cache Key: tab_${_tabController.index}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
