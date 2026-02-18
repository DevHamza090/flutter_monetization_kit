import 'package:flutter/material.dart';
import '../core/enums/native_type.dart';

class NativeShimmer extends StatelessWidget {
  final NativeType designId;
  final double? width;
  final double? height;

  const NativeShimmer({
    super.key,
    required this.designId,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? _getDefaultHeight(),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: _buildLayout(),
    );
  }

  double _getDefaultHeight() {
    switch (designId) {
      case NativeType.native1:
      case NativeType.native2:
        return 100;
      case NativeType.native3:
      case NativeType.native4:
        return 150;
      default:
        return 300;
    }
  }

  Widget _buildLayout() {
    switch (designId) {
      case NativeType.native1:
        return Row(
          children: [
            _box(50, 50),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: _box(double.infinity, 15)),
                  const SizedBox(height: 8),
                  _box(100, 10),
                ],
              ),
            ),
          ],
        );
      // Add cases for native2-native10 with specific layouts
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(40, 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(double.infinity, 12),
                      const SizedBox(height: 4),
                      _box(80, 8),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _box(double.infinity, 80)),
            const SizedBox(height: 12),
            _box(double.infinity, 36),
          ],
        );
    }
  }

  Widget _box(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
