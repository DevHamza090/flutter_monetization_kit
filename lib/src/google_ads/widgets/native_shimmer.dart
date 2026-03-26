import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/enums/native_type.dart';
import '../core/native_ad_style.dart';
import '../core/native_ad_shimmer_style.dart';

class NativeShimmer extends StatelessWidget {
  final NativeType type;
  final NativeAdStyle style;
  final NativeAdShimmerStyle shimmerStyle;
  final double height;

  const NativeShimmer({
    super.key,
    required this.type,
    required this.style,
    required this.shimmerStyle,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: shimmerStyle.bgColor ?? style.bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(shimmerStyle.bgCorner),
        border: Border.all(
          color:
              shimmerStyle.bgStrokeColor ??
              style.bgStrokeColor ??
              Colors.transparent,
          width: shimmerStyle.bgStrokeWidth,
        ),
      ),
      padding: type == NativeType.small3 ||
              type == NativeType.small4 ||
              type == NativeType.small5 ||
              type == NativeType.small6 ||
              type == NativeType.small7
          ? EdgeInsets.zero
          : const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: shimmerStyle.baseColor ?? Colors.grey[300]!,
        highlightColor: shimmerStyle.highlightColor ?? Colors.grey[100]!,
        child: _buildShimmerForType(),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // AD Badge — real styled widget, not a shimmer block (matches native_widget
  // AD badge colour from user style).
  // ──────────────────────────────────────────────────────────────────────────
  Widget _adBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: shimmerStyle.adTextBgColor ?? Colors.amber,
        borderRadius: BorderRadius.circular(shimmerStyle.adTextBgCorner),
      ),
      child: Text(
        'AD',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: shimmerStyle.adTextColor ?? Colors.white,
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Dispatcher
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildShimmerForType() {
    switch (type) {
      case NativeType.small1:
        return _buildSmall1Shimmer();
      case NativeType.small2:
        return _buildSmall2Shimmer();
      case NativeType.small3:
        return _buildSmall3Shimmer();
      case NativeType.small4:
        return _buildSmall4Shimmer();
      case NativeType.small5:
        return _buildSmall5Shimmer();
      case NativeType.small6:
        return _buildSmall6Shimmer();
      case NativeType.small7:
        return _buildSmall7Shimmer();
      case NativeType.small8:
        return _buildSmall8Shimmer();
      case NativeType.medium1:
        return _buildMedium1Shimmer();
      case NativeType.medium2:
        return _buildMedium2Shimmer();
      case NativeType.medium3:
        return _buildMedium3Shimmer();
      case NativeType.medium4:
        return _buildMedium4Shimmer();
      case NativeType.medium5:
        return _buildMedium5Shimmer();
      case NativeType.medium6:
        return _buildMedium6Shimmer();
      case NativeType.large1:
        return _buildLarge1Shimmer();
      case NativeType.large2:
        return _buildLarge2Shimmer();
      case NativeType.large3:
        return _buildLarge3Shimmer();
      case NativeType.large4:
        return _buildLarge4Shimmer();
      case NativeType.large5:
        return _buildLarge5Shimmer();
      case NativeType.large6:
        return _buildLarge6Shimmer();
      default:
        return _buildSmall1Shimmer();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SMALL TEMPLATES
  // ══════════════════════════════════════════════════════════════════════════

  /// small1 — iOS: icon(56) left | [badge+headline / body] middle | button(36h,80w+) right, v-centred
  Widget _buildSmall1Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(width: 8),

        // Text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge + headline row
              Row(
                children: [
                  _adBadge(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(height: 14, color: shimmerStyle.onBgColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Body line
              Container(
                height: 12,
                width: double.infinity,
                color: shimmerStyle.onBgColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // CTA button
        Container(
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  /// small2 / small8 — iOS: no icon | [badge+headline / body] left | button(36h,80w+) right, v-centred
  Widget _buildSmall2Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Text block
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  _adBadge(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(height: 14, color: shimmerStyle.onBgColor),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: double.infinity,
                color: shimmerStyle.onBgColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // CTA button
        Container(
          width: 80,
          height: 36,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  /// small3 — iOS: icon(56) left | [badge+headline / body / adv+rating] | full-height button right (right-rounded only)
  Widget _buildSmall3Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Content side (with internal padding)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: shimmerStyle.onBgColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),

                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _adBadge(),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 14,
                              color: shimmerStyle.onBgColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(height: 4),
                      // Advertiser + rating placeholder
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 10,
                            color: shimmerStyle.onBgColor,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 40,
                            height: 10,
                            color: shimmerStyle.onBgColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Full-height CTA (right-rounded corners only)
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  /// small4 — iOS: icon(56) left | [badge+headline / body(2-line) ] | full-height button right
  Widget _buildSmall4Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Content side
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: shimmerStyle.onBgColor,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                const SizedBox(width: 8),

                // Text block
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _adBadge(),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Container(
                              height: 14,
                              color: shimmerStyle.onBgColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(height: 3),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Full-height CTA
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  /// small5 — iOS: NO icon | [badge+headline / body(1-line)] | full-height button right
  Widget _buildSmall5Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _adBadge(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 14,
                        color: shimmerStyle.onBgColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: shimmerStyle.onBgColor,
                ),
              ],
            ),
          ),
        ),

        // Full-height CTA
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  /// small6 — iOS: NO icon | [badge+headline / body(2-line)] | full-height button right
  Widget _buildSmall6Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _adBadge(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 14,
                        color: shimmerStyle.onBgColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: shimmerStyle.onBgColor,
                ),
                const SizedBox(height: 3),
                Container(
                  height: 12,
                  width: double.infinity,
                  color: shimmerStyle.onBgColor,
                ),
              ],
            ),
          ),
        ),

        // Full-height CTA
        Container(
          width: 80,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(shimmerStyle.bgCorner),
            ),
          ),
        ),
      ],
    );
  }

  /// small7 — iOS: NO icon | [badge+headline / body(1-line)] | full-height button right
  Widget _buildSmall7Shimmer() => _buildSmall5Shimmer();

  /// small8 — same layout as small2 (no icon)
  Widget _buildSmall8Shimmer() => _buildSmall2Shimmer();

  // ══════════════════════════════════════════════════════════════════════════
  // MEDIUM TEMPLATES
  // ══════════════════════════════════════════════════════════════════════════

  /// medium1 — iOS: mediaView left 45% | right 55%: [icon(56)+badge+headline / body / fullBtn(44h)] bottom
  Widget _buildMedium1Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Media left 45%
        Expanded(
          flex: 45,
          child: Container(
            decoration: BoxDecoration(
              color: shimmerStyle.onBgColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Right column 55%
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon + badge + headline
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: shimmerStyle.onBgColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _adBadge(),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 14,
                                color: shimmerStyle.onBgColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Body lines
              Container(height: 12, color: shimmerStyle.onBgColor),
              const SizedBox(height: 4),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const Spacer(),

              // Full-width CTA
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: shimmerStyle.onBgColor,
                  borderRadius:
                      BorderRadius.circular(style.buttonCornerRadius),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// medium2 — iOS: mirror of medium1 (media right)
  Widget _buildMedium2Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left column 55%
        Expanded(
          flex: 55,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon + badge + headline
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: shimmerStyle.onBgColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _adBadge(),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Container(
                                height: 14,
                                color: shimmerStyle.onBgColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const SizedBox(height: 4),
              Container(height: 12, color: shimmerStyle.onBgColor),
              const Spacer(),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: shimmerStyle.onBgColor,
                  borderRadius:
                      BorderRadius.circular(style.buttonCornerRadius),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Media right 45%
        Expanded(
          flex: 45,
          child: Container(
            decoration: BoxDecoration(
              color: shimmerStyle.onBgColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ],
    );
  }

  /// medium3 — iOS: icon(56) left | [badge+headline / body / adv+rating+price] | fullBtn(48h) bottom
  Widget _buildMedium3Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top content row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(width: 12),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge + headline
                    Row(
                      children: [
                        _adBadge(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                    const SizedBox(height: 6),
                    // Advertiser + rating + price row
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 36,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Full-width CTA button at bottom
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  /// medium4 — iOS: fullBtn(48h) top | icon(56) left | [badge+headline / body / adv+rating+price]
  Widget _buildMedium4Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-width CTA button at top
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 12),

        // Bottom content row
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _adBadge(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 36,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// medium5 — iOS: icon(56) left | [badge+headline / body] | fullBtn(48h) bottom (no adv/rating/price)
  Widget _buildMedium5Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _adBadge(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  /// medium6 — iOS: fullBtn(48h) top | icon(56) left | [badge+headline / body] (no adv/rating/price)
  Widget _buildMedium6Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _adBadge(),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 16,
                            color: shimmerStyle.onBgColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(height: 12, color: shimmerStyle.onBgColor),
                    const SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 100,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // LARGE TEMPLATES
  // ══════════════════════════════════════════════════════════════════════════

  /// large1 — iOS: icon(64)+badge+headline / body / adv+price top | mediaView middle | fullBtn(40h) bottom
  Widget _buildLarge1Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top row: icon + text block
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              color: shimmerStyle.onBgColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 8),
                  // Advertiser + price row
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // MediaView
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
        const SizedBox(height: 8),

        // Full-width CTA button
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
      ],
    );
  }

  /// large2 — iOS: fullBtn(40h) top | icon(64)+badge+headline/body/adv+price middle | mediaView bottom
  Widget _buildLarge2Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-width CTA button at top
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 8),

        // Icon + text row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              color: shimmerStyle.onBgColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // MediaView
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
      ],
    );
  }

  /// large3 — iOS: icon(64)+text top | fullBtn(40h) middle | mediaView bottom
  Widget _buildLarge3Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon + text row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 64,
              height: 64,
              color: shimmerStyle.onBgColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const Spacer(),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Full-width CTA button
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 8),

        // MediaView
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
      ],
    );
  }

  /// large4 — iOS: fullBtn(40h) top | [badge+headline/body/adv left, icon(64) right] | mediaView bottom
  Widget _buildLarge4Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Full-width CTA button at top
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(style.buttonCornerRadius),
          ),
        ),
        const SizedBox(height: 8),

        // Icon (right) + text (left) row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text block (left)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 18,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Icon on the right
            Container(
              width: 64,
              height: 64,
              color: shimmerStyle.onBgColor,
            ),
          ],
        ),
        const SizedBox(height: 8),

        // MediaView
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
      ],
    );
  }

  /// large5 — iOS: mediaView top | icon(56)+badge+headline/body/adv left | button(36h,80w+) right, v-centred
  Widget _buildLarge5Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // MediaView top
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
        const SizedBox(height: 8),

        // Bottom bar: icon + text + button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              color: shimmerStyle.onBgColor,
            ),
            const SizedBox(width: 8),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 6),
                  // Advertiser / rating / price row
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // CTA button (right, v-centred to icon)
            Container(
              width: 80,
              height: 36,
              decoration: BoxDecoration(
                color: shimmerStyle.onBgColor,
                borderRadius:
                    BorderRadius.circular(style.buttonCornerRadius),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// large6 — iOS: [icon(56) left, text middle, button(40h,80w+) right] top | mediaView bottom
  Widget _buildLarge6Shimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top bar: icon + text + button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              color: shimmerStyle.onBgColor,
            ),
            const SizedBox(width: 8),

            // Text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _adBadge(),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 16,
                          color: shimmerStyle.onBgColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 12, color: shimmerStyle.onBgColor),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 36,
                        height: 10,
                        color: shimmerStyle.onBgColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // CTA button (right, v-centred to icon)
            Container(
              width: 80,
              height: 40,
              decoration: BoxDecoration(
                color: shimmerStyle.onBgColor,
                borderRadius:
                    BorderRadius.circular(style.buttonCornerRadius),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // MediaView bottom
        Expanded(
          child: Container(color: shimmerStyle.onBgColor),
        ),
      ],
    );
  }
}
