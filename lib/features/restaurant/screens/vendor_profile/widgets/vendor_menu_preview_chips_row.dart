import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_product/vendor_product_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_category_chip.dart';

class VendorMenuPreviewChipsRow extends StatelessWidget {
  const VendorMenuPreviewChipsRow({
    super.key,
    required this.groups,
    required this.activeCategoryId,
    required this.chipsScrollController,
    required this.chipsRowKey,
    required this.chipKeys,
    required this.onChipTap, //
  });

  final List<VendorProductGroupModel> groups;
  final int activeCategoryId;
  final ScrollController chipsScrollController;
  final GlobalKey chipsRowKey;
  final Map<int, GlobalKey> chipKeys;
  final void Function(VendorProductGroupModel group) onChipTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StaticColors.cF8F8F8,
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: chipsScrollController,
        scrollDirection: Axis.horizontal,
        child: Row(
          key: chipsRowKey,
          children: [
            for (final g in groups)
              Padding(
                key: chipKeys[g.id],
                padding: const EdgeInsets.only(right: 8),
                child: VendorCategoryChip(
                  label: g.name,
                  selected: activeCategoryId == g.id,
                  onTap: () {
                    onChipTap(g);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
