import 'package:flutter/material.dart';
import 'package:flutter_monetization_kit/easy_ads.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({Key? key}) : super(key: key);

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BannerType _getBannerType(int index) {
    switch (index) {
      case 0:
        return BannerType.standard;
      case 1:
        return BannerType.adaptive;
      case 2:
        return BannerType.large;
      case 3:
        return BannerType.rectangle;
      case 4:
        return const CollapsibleBanner(isTop: false);
      default:
        return BannerType.standard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ads Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Standard'),
            Tab(text: 'Adaptive'),
            Tab(text: 'Large'),
            Tab(text: 'Rectangle'),
            Tab(text: 'Collapsible'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BannerDemo(title: 'Standard Banner'),
          BannerDemo(title: 'Adaptive Banner'),
          BannerDemo(title: 'Large Banner'),
          BannerDemo(title: 'Rectangle Banner'),
          BannerDemo(title: 'Collapsible Banner'),
          CustomBannerDemo(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.grey[100],
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Bottom Ad Placement',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              if (_tabController.index != 5) // Not Custom
                BannerAdWidget(
                  key: ValueKey('bottom_ad_${_tabController.index}'),
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  type: _getBannerType(_tabController.index),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Go to Custom tab to configure sizes'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BannerDemo extends StatelessWidget {
  final String title;

  const BannerDemo({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ad_units, size: 64, color: Colors.blue.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
            'The ad for this type is displayed at the bottom.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class CustomBannerDemo extends StatefulWidget {
  const CustomBannerDemo({Key? key}) : super(key: key);

  @override
  State<CustomBannerDemo> createState() => _CustomBannerDemoState();
}

class _CustomBannerDemoState extends State<CustomBannerDemo> {
  final _heightController = TextEditingController(text: '50');
  final _widthController = TextEditingController(text: '320');
  bool _useWidth = true;

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text(
            'Custom Dimensions',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    helperText: 'Standard min: 50',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              if (_useWidth)
                Expanded(
                  child: TextField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width',
                      helperText: 'Standard min: 320',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
            ],
          ),
          SwitchListTile(
            title: const Text('Specify Custom Width'),
            subtitle: const Text('Otherwise uses full screen width'),
            value: _useWidth,
            onChanged: (val) => setState(() => _useWidth = val),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text('Apply & Reload'),
          ),
          const Divider(height: 40),
          Expanded(
            child: Center(
              child: BannerAdWidget(
                key: UniqueKey(), // Force reload on apply
                type: _useWidth
                    ? CustomSizeBanner(
                        int.tryParse(_widthController.text) ?? 320,
                        int.tryParse(_heightController.text) ?? 50,
                      )
                    : CustomHeightBanner(
                        int.tryParse(_heightController.text) ?? 50,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
