import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_overview_card.dart';

class VendorOverviewGrid extends StatelessWidget {
  const VendorOverviewGrid({
    super.key,
    required this.crossAxisCount,
    required this.isWide,
    required this.items,
    required this.isLoading,
  });

  final int crossAxisCount;
  final bool isWide;
  final List<VendorOverviewCardData> items;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, index) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            return SizedBox(
              width: 210,
              child: VendorOverviewCard(
                item: items[index],
                isLoading: isLoading,
              ),
            );
          },
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: crossAxisCount == 4 ? 1.2 : 1.8,
      ),
      itemBuilder: (context, index) {
        return VendorOverviewCard(
          item: items[index],
          isLoading: isLoading,
        );
      },
    );
  }
}
