import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_most_active_customers_card.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/widgets/vendor_sales_distribution_card.dart';

class VendorSalesAndCustomersSection extends StatelessWidget {
  const VendorSalesAndCustomersSection({
    super.key,
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (isWide) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: VendorSalesDistributionCard()),
          SizedBox(width: 12),
          Expanded(child: VendorMostActiveCustomersCard()),
        ],
      );
    }

    return const Column(
      children: [
        VendorSalesDistributionCard(),
        SizedBox(height: 12),
        VendorMostActiveCustomersCard(),
      ],
    );
  }
}
