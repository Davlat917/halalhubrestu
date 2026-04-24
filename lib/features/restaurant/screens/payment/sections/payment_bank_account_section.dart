import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';

class PaymentBankAccountSection extends StatelessWidget {
  const PaymentBankAccountSection({
    super.key,
    required this.status,
    required this.bankInfo,
    required this.errorMessage,
    required this.onRetry,
    required this.onEditPressed,
  });

  final PaymentDashboardStatus status;
  final VendorBankInfoModel bankInfo;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onEditPressed;

  @override
  Widget build(BuildContext context) {
    if (status == PaymentDashboardStatus.loading ||
        status == PaymentDashboardStatus.initial) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StaticColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StaticColors.cE2E2E2),
        ),
        child: const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }

    if (status == PaymentDashboardStatus.failure) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: StaticColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: StaticColors.cE2E2E2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              TranslationKeys.paymentBankAccount.tr(context: context),
              style: AppTextStyle.medium14(context),
            ),
            const SizedBox(height: 10),
            Text(
              errorMessage ??
                  TranslationKeys.paymentFailedLoadBankInfo.tr(
                    context: context,
                  ),
              style: AppTextStyle.regular14(
                context,
                color: StaticColors.c9AA0A6,
              ),
            ),
            const SizedBox(height: 10),
            CustomButton(
              label: TranslationKeys.retry.tr(context: context),
              onPressed: onRetry,
              backgroundColor: StaticColors.primary,
              foregroundColor: StaticColors.white,
              borderRadius: 10,
              height: 40,
              width: 120,
              textStyle: AppTextStyle.medium16(
                context,
                size: 14,
                color: StaticColors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TranslationKeys.paymentBankAccount.tr(context: context),
            style: AppTextStyle.medium14(context),
          ),
          const SizedBox(height: 12),
          _BankInfoRow(
            TranslationKeys.paymentFullBusinessName.tr(context: context),
            bankInfo.businessName,
          ),
          const SizedBox(height: 10),
          _BankInfoRow(
            TranslationKeys.paymentEinNumber.tr(context: context),
            bankInfo.einNumberMasked,
          ),
          const SizedBox(height: 10),
          _BankInfoRow(
            TranslationKeys.paymentAccountNumber.tr(context: context),
            bankInfo.accountNumberMasked,
          ),
          const SizedBox(height: 10),
          _BankInfoRow(
            TranslationKeys.paymentRoutingNumber.tr(context: context),
            bankInfo.routingNumberMasked,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: CustomButton(
              label: TranslationKeys.paymentEditBankAccount.tr(
                context: context,
              ),
              onPressed: onEditPressed,
              backgroundColor: StaticColors.primary,
              foregroundColor: StaticColors.white,
              borderRadius: 10,
              height: 40,
              textStyle: AppTextStyle.medium16(
                context,
                size: 14,
                color: StaticColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BankInfoRow extends StatelessWidget {
  const _BankInfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.regular12(context, color: StaticColors.c666666),
          ),
        ),
        Text(value, style: AppTextStyle.regular12(context)),
      ],
    );
  }
}
