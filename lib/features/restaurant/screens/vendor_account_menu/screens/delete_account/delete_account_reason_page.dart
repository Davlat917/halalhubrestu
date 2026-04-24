import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/vendor_account_menu_handlers.dart';

/// Akkauntni o‘chirishdan oldin sabab tanlash.
@RoutePage()
class DeleteAccountReasonPage extends StatefulWidget {
  const DeleteAccountReasonPage({super.key});

  static const List<String> reasonKeys = [
    TranslationKeys.deleteReasonLowUsage,
    TranslationKeys.deleteReasonAnotherAccount,
    TranslationKeys.deleteReasonCommission,
    TranslationKeys.deleteReasonTechnical,
    TranslationKeys.deleteReasonSupport,
    TranslationKeys.deleteReasonOther,
  ];

  @override
  State<DeleteAccountReasonPage> createState() =>
      _DeleteAccountReasonPageState();
}

class _DeleteAccountReasonPageState extends State<DeleteAccountReasonPage> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveSection.isMobileLayout(context);
    final horizontal = isMobile ? 16.0 : 24.0;
    final maxBody = isMobile ? double.infinity : 560.0;

    return Scaffold(
      backgroundColor: StaticColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.white,
        surfaceTintColor: Colors.transparent,
        leading: Align(
          alignment: Alignment.center,
          child: CircleBtnWidget(
            bgColor: StaticColors.white,
            iconColor: StaticColors.black,
            onPress: () => context.router.maybePop(),
          ),
        ),
        title: Text(
          TranslationKeys.deleteAccountTitle.tr(context: context),
          style: AppTextStyle.semibold18(context),
        ),
        centerTitle: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBody),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 16),
                  children: [
                    Text(
                      TranslationKeys.deleteAccountQuestion.tr(
                        context: context,
                      ),
                      style: AppTextStyle.semibold16(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      TranslationKeys.deleteAccountHint.tr(context: context),
                      style: AppTextStyle.regular14(
                        context,
                        color: StaticColors.c666666,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      DeleteAccountReasonPage.reasonKeys.length,
                      (i) {
                        final selected = _selectedIndex == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: StaticColors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => setState(() => _selectedIndex = i),
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? StaticColors.primary
                                        : StaticColors.cE2E2E2,
                                    width: selected ? 1.5 : 1,
                                  ),
                                  color: selected
                                      ? StaticColors.primary.withValues(
                                          alpha: 0.06,
                                        )
                                      : StaticColors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color: selected
                                          ? StaticColors.primary
                                          : StaticColors.c9AA0A6,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        DeleteAccountReasonPage.reasonKeys[i]
                                            .tr(context: context),
                                        style: AppTextStyle.medium16(
                                          context,
                                          size: 15,
                                          color: StaticColors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 12),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxBody),
                  child: LayoutBuilder(
                    builder: (_, c) {
                      final w = c.maxWidth.isFinite
                          ? c.maxWidth
                          : MediaQuery.sizeOf(context).width - horizontal * 2;
                      return CustomButton(
                        label: TranslationKeys.continueText.tr(
                          context: context,
                        ),
                        width: w,
                        height: 50,
                        isDisabled: _selectedIndex == null,
                        textStyle: AppTextStyle.medium14(
                          context,
                          color: StaticColors.white,
                        ),
                        onPressed: _selectedIndex == null
                            ? null
                            : () {
                                final reason = DeleteAccountReasonPage
                                    .reasonKeys[_selectedIndex!]
                                    .tr(context: context);
                                VendorAccountMenuHandlers.showDeleteAccountConfirmDialog(
                                  context,
                                  reasonLabel: reason,
                                );
                              },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
