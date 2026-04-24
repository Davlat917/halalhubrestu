import 'package:flutter/material.dart';

class VendorMenuPreviewPinnedChipsHeaderDelegate extends SliverPersistentHeaderDelegate {
  VendorMenuPreviewPinnedChipsHeaderDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant VendorMenuPreviewPinnedChipsHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}
