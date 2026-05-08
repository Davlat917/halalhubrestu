import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_menu_preview_product_card.dart';

class VendorMenuPreviewProductsGrid extends StatelessWidget {
  const VendorMenuPreviewProductsGrid({
    super.key,
    required this.products,
    required this.onEditProduct,
    required this.onSetProductAvailability,
  });

  final List<VendorProductModel> products;
  final ValueChanged<VendorProductModel> onEditProduct;
  final Future<void> Function(VendorProductModel product, bool isAvailable)
  onSetProductAvailability;

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = _resolveCrossAxisCount(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _resolveCardAspectRatio(context),
      ),
      itemBuilder: (context, index) {
        final p = products[index];
        return VendorMenuPreviewProductCard(
          product: p,
          onEditTap: () => onEditProduct(p),
          onAvailabilityChange: (v) => onSetProductAvailability(p, v),
        );
      },
    );
  }

  int _resolveCrossAxisCount(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    if (!isTablet) return 1;
    return isLandscape ? 3 : 2;
  }

  double _resolveCardAspectRatio(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    if (!isTablet) return 1.95;
    return isLandscape ? 0.74 : 0.58;
  }
}
