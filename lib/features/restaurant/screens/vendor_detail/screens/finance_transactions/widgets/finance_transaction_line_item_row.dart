import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transaction_item_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_utils.dart';

class FinanceTransactionLineItemRow extends StatelessWidget {
  const FinanceTransactionLineItemRow({super.key, required this.item});

  final VendorFinanceTransactionLineItemModel item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: NetworkImageCache(
            imgUrl: item.image,
            widthW: 56,
            heightH: 56,
            radius: 8,
            placeholder: Container(
              width: 56,
              height: 56,
              color: StaticColors.cF8F8F8,
              child: const Icon(Icons.fastfood_outlined, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: AppTextStyle.semibold14(
                  context,
                  color: StaticColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                TranslationKeys.vendorFinanceTransactionsQuantity.tr(
                  context: context,
                  namedArgs: {'count': '${item.quantity}'},
                ),
                style: AppTextStyle.regular12(
                  context,
                  color: StaticColors.c9AA0A6,
                ),
              ),
              const SizedBox(height: 2),
              RichText(
                text: TextSpan(
                  style: AppTextStyle.regular12(
                    context,
                    color: StaticColors.c9AA0A6,
                  ),
                  children: [
                    TextSpan(
                      text: TranslationKeys.vendorFinanceTransactionsPriceLabel
                          .tr(context: context),
                    ),
                    TextSpan(
                      text: formatFinanceTransactionMoney(item.price),
                      style: AppTextStyle.semibold12(
                        context,
                        color: StaticColors.black,
                      ),
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
}
