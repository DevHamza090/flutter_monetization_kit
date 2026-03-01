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
          color: shimmerStyle.bgStrokeColor ?? style.bgStrokeColor ?? Colors.transparent,
          width: shimmerStyle.bgStrokeWidth,
        ),
      ),
      padding: type == NativeType.small3 ? EdgeInsets.zero : const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: shimmerStyle.baseColor ?? Colors.grey[300]!,
        highlightColor: shimmerStyle.highlightColor ?? Colors.grey[100]!,
        child: _buildShimmerForType(),
      ),
    );
  }

  Widget _buildShimmerForType() {
    switch (type) {
      case NativeType.small4:
        return _buildSmall4Shimmer();
      case NativeType.small3:
        return _buildSmall3Shimmer();
      case NativeType.small2:
        return _buildSmall2Shimmer();
      case NativeType.small1:
      default:
        return _buildSmall1Shimmer();
    }
  }

  Widget _buildSmall1Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon Placeholder
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        const SizedBox(width: 8),
        
        // Text Content Placeholder
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ad Badge + Headline
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: shimmerStyle.adTextBgColor ?? Colors.amber,
                      borderRadius: BorderRadius.circular(shimmerStyle.adTextBgCorner),
                    ),
                    child: Text('AD', 
                      style: TextStyle(
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        color: shimmerStyle.adTextColor ?? Colors.white
                      )
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 120,
                    height: 14,
                    color: shimmerStyle.onBgColor,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Body Text Lines
              Container(
                width: double.infinity,
                height: 12,
                color: shimmerStyle.onBgColor,
              ),
              const SizedBox(height: 4),
              Container(
                width: 150,
                height: 12,
                color: shimmerStyle.onBgColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // CTA Button Placeholder
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

  Widget _buildSmall2Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                     decoration: BoxDecoration(
                       color: shimmerStyle.adTextBgColor ?? Colors.amber,
                       borderRadius: BorderRadius.circular(shimmerStyle.adTextBgCorner),
                     ),
                     child: Text('AD', 
                       style: TextStyle(
                         fontSize: 10, 
                         fontWeight: FontWeight.bold, 
                         color: shimmerStyle.adTextColor ?? Colors.white
                       )
                     ),
                   ),
                   const SizedBox(width: 6),
                   Expanded(
                     child: Container(
                       height: 14,
                       color: shimmerStyle.onBgColor,
                     ),
                   ),
                 ],
               ),
               const SizedBox(height: 6),
               Container(
                 width: double.infinity,
                 height: 12,
                 color: shimmerStyle.onBgColor,
               ),
               const SizedBox(height: 6),
               Row(
                 children: [
                   Container(
                     width: 60,
                     height: 10,
                     color: shimmerStyle.onBgColor,
                   ),
                   const SizedBox(width: 8),
                   Container(
                     width: 80,
                     height: 10,
                     color: shimmerStyle.onBgColor,
                   ),
                 ],
               ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildSmall3Shimmer() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Placeholder
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: shimmerStyle.onBgColor,
                    borderRadius: BorderRadius.circular(16.0), // Rounded corners based on design
                  ),
                ),
                const SizedBox(width: 8),
                
                // Text Content Placeholder
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ad Badge + Headline
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: shimmerStyle.adTextBgColor ?? Colors.amber,
                              borderRadius: BorderRadius.circular(shimmerStyle.adTextBgCorner),
                            ),
                            child: Text('AD', 
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: shimmerStyle.adTextColor ?? Colors.white
                              )
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 100,
                            height: 14,
                            color: shimmerStyle.onBgColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Body Text Lines
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: shimmerStyle.onBgColor,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 10,
                            color: shimmerStyle.onBgColor,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 80,
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
        
        // CTA Button Placeholder matches parent height
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(shimmerStyle.bgCorner)),
          ),
        ),
      ],
    );
  }

  Widget _buildSmall4Shimmer() {
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
                // Ad Badge + Headline
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: shimmerStyle.adTextBgColor ?? Colors.amber,
                        borderRadius: BorderRadius.circular(shimmerStyle.adTextBgCorner),
                      ),
                      child: Text('AD', 
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: shimmerStyle.adTextColor ?? Colors.white
                        )
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: shimmerStyle.onBgColor,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Body Text Lines
                Container(
                  width: double.infinity,
                  height: 12,
                  color: shimmerStyle.onBgColor,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 80,
                          height: 10,
                          color: shimmerStyle.onBgColor,
                        ),
                      ],
                    ),
                    // Price placeholder
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
        ),
        
        // CTA Button Placeholder matches parent height
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: shimmerStyle.onBgColor,
            borderRadius: BorderRadius.horizontal(right: Radius.circular(shimmerStyle.bgCorner)),
          ),
        ),
      ],
    );
  }
}
