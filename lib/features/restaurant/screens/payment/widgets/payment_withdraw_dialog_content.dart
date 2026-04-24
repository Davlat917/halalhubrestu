import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';

class PaymentWithdrawDialogContent extends StatefulWidget {
  const PaymentWithdrawDialogContent({
    super.key,
    required this.maxBalanceLabel,
    required this.onClose,
    required this.onSubmit,
  });

  final String maxBalanceLabel;
  final VoidCallback onClose;
  final void Function(String amountText) onSubmit;

  @override
  State<PaymentWithdrawDialogContent> createState() =>
      _PaymentWithdrawDialogContentState();
}

class _PaymentWithdrawDialogContentState
    extends State<PaymentWithdrawDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationKeys.paymentBankAccount.tr(context: context),
                  style: AppTextStyle.medium18(context),
                ),
              ),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: StaticColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 150,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: StaticColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationKeys.paymentCurrentBalance.tr(context: context),
                    style: AppTextStyle.medium14(
                      context,
                      color: StaticColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.maxBalanceLabel,
                    style: AppTextStyle.bold24(
                      context,
                      color: StaticColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            TranslationKeys.paymentAmount.tr(context: context),
            style: AppTextStyle.medium16(context),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: CommonTextField(
              controller: _controller,
              hint: TranslationKeys.paymentMaxHint.tr(
                context: context,
                namedArgs: {'value': widget.maxBalanceLabel},
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatter: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              background: StaticColors.cF8F8F8,
              enabledBorderColor: StaticColors.cE2E2E2,
              focusedBorderColor: StaticColors.primary,
              textSize: 14,
              textFontWeight: FontWeight.w400,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffix: SvgPicture.asset(
                'assets/icons/vakum.svg',
                width: 18,
                height: 18,
              ),
              suffixPressed: () {
                _controller.text = widget.maxBalanceLabel.replaceAll('\$', '').trim();
                _controller.selection = TextSelection.collapsed(
                  offset: _controller.text.length,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<PaymentDashboardBloc, PaymentDashboardState>(
            buildWhen: (previous, current) {
              return previous.withdrawRequestStatus !=
                  current.withdrawRequestStatus;
            },
            builder: (context, state) {
              final busy =
                  state.withdrawRequestStatus == PaymentDashboardStatus.loading;
              return Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      label: TranslationKeys.cancel.tr(context: context),
                      onPressed: busy ? null : widget.onClose,
                      backgroundColor: const Color(0xFFEAF8EF),
                      foregroundColor: StaticColors.primary,
                      height: 50,
                      borderRadius: 12,
                      textStyle: AppTextStyle.medium16(
                        context,
                        size: 14,
                        color: StaticColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      label: TranslationKeys.paymentSendRequest.tr(
                        context: context,
                      ),
                      onPressed: busy
                          ? null
                          : () => widget.onSubmit(_controller.text),
                      backgroundColor: StaticColors.primary,
                      foregroundColor: StaticColors.white,
                      height: 50,
                      borderRadius: 12,
                      textStyle: AppTextStyle.medium16(
                        context,
                        size: 14,
                        color: StaticColors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
