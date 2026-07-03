import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/utils/payment_stripe_details_utils.dart';

class PaymentStripeCheckSection extends StatelessWidget {
  const PaymentStripeCheckSection({
    super.key,
    required this.status,
    required this.isConnected,
    required this.chargesEnabled,
    required this.requirements,
    required this.detailsEn,
    this.errorMessage,
    required this.onCheckPressed,
    required this.connectStatus,
    required this.onConnectPressed,
  });

  final PaymentDashboardStatus status;
  final bool isConnected;
  final bool chargesEnabled;
  final List<String> requirements;
  final String detailsEn;
  final String? errorMessage;
  final VoidCallback onCheckPressed;
  final PaymentDashboardStatus connectStatus;
  final VoidCallback onConnectPressed;

  @override
  Widget build(BuildContext context) {
    final isLoading = status == PaymentDashboardStatus.loading;
    final hasResult = status == PaymentDashboardStatus.success;
    final hasFailed = status == PaymentDashboardStatus.failure;
    final isConnectLoading = connectStatus == PaymentDashboardStatus.loading;
    final isFullyReady =
        isConnected && chargesEnabled && requirements.isEmpty;
    final showConnectButton = hasResult && !isFullyReady;

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
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationKeys.paymentStripeAccount.tr(context: context),
                  style: AppTextStyle.medium14(context),
                ),
              ),
              SizedBox(
                width: 120,
                height: 40,
                child: CustomButton(
                  label: isLoading
                      ? TranslationKeys.paymentStripeChecking.tr(
                          context: context,
                        )
                      : TranslationKeys.paymentStripeCheck.tr(context: context),
                  onPressed: isLoading ? null : onCheckPressed,
                  isLoading: isLoading,
                  backgroundColor: StaticColors.primary,
                  foregroundColor: StaticColors.white,
                  borderRadius: 10,
                  height: 40,
                  textStyle: AppTextStyle.medium16(
                    context,
                    size: 13,
                    color: StaticColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StripeCheckResultBody(
            hasResult: hasResult,
            hasFailed: hasFailed,
            isConnected: isConnected,
            chargesEnabled: chargesEnabled,
            requirements: requirements,
            detailsEn: detailsEn,
            errorMessage: errorMessage,
          ),
          if (showConnectButton) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 44,
              child: CustomButton(
                label: isConnectLoading
                    ? TranslationKeys.paymentStripeConnecting.tr(
                        context: context,
                      )
                    : TranslationKeys.paymentStripeConnect.tr(context: context),
                onPressed: isConnectLoading || isLoading ? null : onConnectPressed,
                isLoading: isConnectLoading,
                backgroundColor: StaticColors.primary,
                foregroundColor: StaticColors.white,
                borderRadius: 10,
                height: 44,
                textStyle: AppTextStyle.medium16(
                  context,
                  size: 14,
                  color: StaticColors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StripeCheckResultBody extends StatelessWidget {
  const _StripeCheckResultBody({
    required this.hasResult,
    required this.hasFailed,
    required this.isConnected,
    required this.chargesEnabled,
    required this.requirements,
    required this.detailsEn,
    this.errorMessage,
  });

  final bool hasResult;
  final bool hasFailed;
  final bool isConnected;
  final bool chargesEnabled;
  final List<String> requirements;
  final String detailsEn;
  final String? errorMessage;

  bool get _isFullyReady =>
      isConnected && chargesEnabled && requirements.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (hasFailed) {
      return _StripeStatusBox(
        backgroundColor: const Color(0xFFFFEEEE),
        borderColor: const Color(0xFFFF8A8A),
        icon: Icons.error_outline_rounded,
        iconColor: StaticColors.cFF4E4E,
        title: TranslationKeys.paymentStripeCheckFailed.tr(context: context),
        description: errorMessage ??
            TranslationKeys.paymentStripeCheckFailed.tr(context: context),
        titleColor: StaticColors.cFF4E4E,
      );
    }

    if (!hasResult) {
      return Text(
        TranslationKeys.paymentStripeCheckHint.tr(context: context),
        style: AppTextStyle.regular14(
          context,
          color: StaticColors.c666666,
        ),
      );
    }

    if (isConnected) {
      if (_isFullyReady) {
        return _StripeStatusBox(
          backgroundColor: StaticColors.primary.withValues(alpha: 0.07),
          borderColor: StaticColors.primary.withValues(alpha: 0.35),
          icon: Icons.check_circle_outline_rounded,
          iconColor: StaticColors.primary,
          title: TranslationKeys.paymentStripeConnectedTitle.tr(
            context: context,
          ),
          description: PaymentStripeDetailsUtils.connectedReadyEn,
          titleColor: StaticColors.primary,
        );
      }

      return _StripeStatusBox(
        backgroundColor: const Color(0xFFFFF4E5),
        borderColor: const Color(0xFFFFB84D),
        icon: Icons.pending_outlined,
        iconColor: const Color(0xFFE67E00),
        title: TranslationKeys.paymentStripeConnectedIncompleteTitle.tr(
          context: context,
        ),
        description: detailsEn.isNotEmpty
            ? detailsEn
            : PaymentStripeDetailsUtils.connectedIncompleteIntroEn,
        titleColor: const Color(0xFFB35C00),
      );
    }

    return _StripeStatusBox(
      backgroundColor: const Color(0xFFFFF4E5),
      borderColor: const Color(0xFFFFB84D),
      icon: Icons.link_off_rounded,
      iconColor: const Color(0xFFE67E00),
      title: TranslationKeys.paymentStripeNotConnectedTitle.tr(context: context),
      description: detailsEn.isNotEmpty
          ? detailsEn
          : PaymentStripeDetailsUtils.notConnectedDefaultEn,
      titleColor: const Color(0xFFB35C00),
    );
  }
}

class _StripeStatusBox extends StatelessWidget {
  const _StripeStatusBox({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.titleColor,
  });

  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.semibold16(context, color: titleColor),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyle.regular14(
                    context,
                    color: StaticColors.c4C4C4C,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
