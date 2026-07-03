import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';

class PaymentEditBankAccountDialogContent extends StatelessWidget {
  const PaymentEditBankAccountDialogContent({
    super.key,
    required this.onClose,
    required this.onSubmit,
    required this.submitStatus,
    required this.submitErrorMessage,
    required this.businessNameController,
    required this.einController,
    required this.accountNumberController,
    required this.routingNumberController,
    required this.payoutScheduleListenable,
    required this.businessNameErrorListenable,
    required this.einErrorListenable,
    required this.accountNumberErrorListenable,
    required this.routingNumberErrorListenable,
    required this.onWeeklySelected,
    required this.onManualSelected,
    required this.onBusinessNameChanged,
    required this.onEinChanged,
    required this.onAccountNumberChanged,
    required this.onRoutingNumberChanged,
  });

  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final PaymentDashboardStatus submitStatus;
  final String? submitErrorMessage;
  final TextEditingController businessNameController;
  final TextEditingController einController;
  final TextEditingController accountNumberController;
  final TextEditingController routingNumberController;
  final ValueNotifier<String> payoutScheduleListenable;
  final ValueNotifier<String?> businessNameErrorListenable;
  final ValueNotifier<String?> einErrorListenable;
  final ValueNotifier<String?> accountNumberErrorListenable;
  final ValueNotifier<String?> routingNumberErrorListenable;
  final VoidCallback onWeeklySelected;
  final VoidCallback onManualSelected;
  final ValueChanged<String> onBusinessNameChanged;
  final ValueChanged<String> onEinChanged;
  final ValueChanged<String> onAccountNumberChanged;
  final ValueChanged<String> onRoutingNumberChanged;
  static const double _dialogReferenceWidth = 420;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationKeys.paymentBankAccount.tr(context: context),
                  style: AppTextStyle.semibold20(context, size: 18),
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: StaticColors.primary,
                ),
              ),
            ],
          ),
          ValueListenableBuilder<String>(
            valueListenable: payoutScheduleListenable,
            builder: (context, payoutSchedule, _) {
              return Column(
                children: [
                  _PayoutScheduleTile(
                    title: TranslationKeys.paymentWeeklyAutomaticPayout.tr(
                      context: context,
                    ),
                    subtitle: TranslationKeys
                        .paymentWeeklyAutomaticPayoutSubtitle
                        .tr(context: context),
                    selected: payoutSchedule == 'weekly',
                    onTap: onWeeklySelected,
                  ),
                  const SizedBox(height: 10),
                  _PayoutScheduleTile(
                    title: TranslationKeys.paymentManualWithdrawal.tr(
                      context: context,
                    ),
                    subtitle: TranslationKeys.paymentManualWithdrawalSubtitle
                        .tr(context: context),
                    selected: payoutSchedule == 'manual',
                    onTap: onManualSelected,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Text(
            TranslationKeys.paymentFullBusinessName.tr(context: context),
            style: AppTextStyle.medium16(context, size: 14),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: businessNameErrorListenable,
            builder: (context, error, _) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: CommonTextField(
                  controller: businessNameController,
                  hint: TranslationKeys.paymentBusinessNameHint.tr(
                    context: context,
                  ),
                  maxLength: 255,
                  errorText: error,
                  onChanged: onBusinessNameChanged,
                  availableWidth: _dialogReferenceWidth,
                  textSize: 14,
                  textFontWeight: FontWeight.w400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            TranslationKeys.paymentEinNumber.tr(context: context),
            style: AppTextStyle.medium16(context, size: 14),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: einErrorListenable,
            builder: (context, error, _) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: CommonTextField(
                  controller: einController,
                  hint: TranslationKeys.paymentEinHint.tr(context: context),
                  mask: '##-#######',
                  keyboardType: TextInputType.number,
                  errorText: error,
                  onChanged: onEinChanged,
                  availableWidth: _dialogReferenceWidth,
                  textSize: 14,
                  textFontWeight: FontWeight.w400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            TranslationKeys.paymentAccountNumber.tr(context: context),
            style: AppTextStyle.medium16(context, size: 14),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: accountNumberErrorListenable,
            builder: (context, error, _) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: CommonTextField(
                  controller: accountNumberController,
                  hint: TranslationKeys.paymentAccountHint.tr(context: context),
                  keyboardType: TextInputType.number,
                  maxLength: 12,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(12),
                  ],
                  errorText: error,
                  onChanged: onAccountNumberChanged,
                  availableWidth: _dialogReferenceWidth,
                  textSize: 14,
                  textFontWeight: FontWeight.w400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            TranslationKeys.paymentRoutingNumber.tr(context: context),
            style: AppTextStyle.medium16(context, size: 14),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<String?>(
            valueListenable: routingNumberErrorListenable,
            builder: (context, error, _) {
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 50),
                child: CommonTextField(
                  controller: routingNumberController,
                  hint: TranslationKeys.paymentRoutingHint.tr(context: context),
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  errorText: error,
                  onChanged: onRoutingNumberChanged,
                  availableWidth: _dialogReferenceWidth,
                  textSize: 14,
                  textFontWeight: FontWeight.w400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: CustomButton(
              label: submitStatus == PaymentDashboardStatus.loading
                  ? TranslationKeys.paymentSubmitting.tr(context: context)
                  : TranslationKeys.paymentSubmit.tr(context: context),
              onPressed: submitStatus == PaymentDashboardStatus.loading
                  ? null
                  : onSubmit,
              backgroundColor: StaticColors.primary,
              foregroundColor: StaticColors.white,
              borderRadius: 12,
              height: 50,
              textStyle: AppTextStyle.medium16(
                context,
                size: 14,
                color: StaticColors.white,
              ),
            ),
          ),
          if (submitStatus == PaymentDashboardStatus.failure &&
              submitErrorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              submitErrorMessage!,
              style: AppTextStyle.regular14(context, color: Colors.red),
            ),
          ],
        ],
      ),
    );
  }
}

class PaymentEditBankAccountFormData {
  const PaymentEditBankAccountFormData({
    required this.businessName,
    required this.payoutSchedule,
    required this.einNumber,
    required this.accountNumber,
    required this.routingNumber,
  });

  final String businessName;
  final String payoutSchedule;
  final String einNumber;
  final String accountNumber;
  final String routingNumber;
}

class _PayoutScheduleTile extends StatelessWidget {
  const _PayoutScheduleTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF8EF) : StaticColors.cF8F8F8,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? StaticColors.primary : StaticColors.c9AA0A6,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyle.medium16(
                      context,
                      size: 14,
                      color: selected
                          ? StaticColors.primary
                          : StaticColors.c4C4C4C,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyle.regular14(
                      context,
                      size: 12,
                      color: StaticColors.c666666,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
