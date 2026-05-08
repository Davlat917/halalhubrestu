import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/mixins/sign_in_tab_mixin.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/widgets/sign_in_email_widget.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/widgets/sign_in_phone_widget.dart';

class SignInCardSection extends StatefulWidget {
  final double? availableWidth;
  final double? availableHeight;
  final double? buttonHeight;

  const SignInCardSection({
    super.key,
    this.availableWidth,
    this.availableHeight,
    this.buttonHeight,
  });

  @override
  State<SignInCardSection> createState() => _SignInCardSectionState();
}

class _SignInCardSectionState extends State<SignInCardSection>
    with SignInTabMixin {
  @override
  Widget build(BuildContext context) {
    final aW = widget.availableWidth ?? context.screenWidth;
    final aH = widget.availableHeight ?? context.screenHeight;
    return DefaultTabController(
      length: 2,
      child: SizedBox(
        height: aH,
        width: aW,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: aH),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  // constraints: const BoxConstraints(maxWidth: 480),
                  margin: EdgeInsets.all(context.wOf(16, aW)),
                  padding: EdgeInsets.all(context.wOf(20, aW)),
                  decoration: BoxDecoration(
                    color: StaticColors.white,
                    borderRadius: BorderRadius.circular(context.wOf(20, aW)),
                    border: Border.all(color: StaticColors.cE2E2E2),
                  ),
                  child: Column(
                    spacing: context.wOf(20, aW),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TranslationKeys.authSignInTitle.tr(context: context),
                        style: AppTextStyle.medium24(
                          context,
                          color: StaticColors.primary,
                          aW: aW, //
                        ),
                      ),
                      Text(
                        TranslationKeys.authSignInSubtitle.tr(context: context),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.regular16(
                          context,
                          color: StaticColors.cBDC1C6,
                          aW: aW,
                        ),
                      ),

                      // TabBar
                      Container(
                        height: widget.buttonHeight ?? context.wOf(48, aW),
                        decoration: BoxDecoration(
                          color: StaticColors.cE2E2E2.withAlpha(135),
                          borderRadius: BorderRadius.circular(
                            context.wOf(10, aW),
                          ),
                        ),
                        child: TabBar(
                          onTap: toggleIndex,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: StaticColors.primary,
                            borderRadius: BorderRadius.circular(
                              context.wOf(10, aW),
                            ),
                          ),
                          labelColor: StaticColors.white,
                          unselectedLabelColor: StaticColors.cBDC1C6,
                          labelStyle: AppTextStyle.medium16(context, aW: aW),
                          tabs: [
                            Tab(
                              text: TranslationKeys.authEmail.tr(
                                context: context,
                              ),
                            ),
                            Tab(
                              text: TranslationKeys.authPhoneNumber.tr(
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),

                      ValueListenableBuilder(
                        valueListenable: currentIndex,
                        builder: (context, value, child) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: value == 0
                                ? SignInEmailWidget(
                                    key: const ValueKey('sign_in_email'),
                                    availableWidth: aW, //
                                    buttonHeight: widget.buttonHeight,
                                  )
                                : SignInPhoneWidget(
                                    key: const ValueKey('sign_in_phone'),
                                    availableWidth: aW, //
                                    buttonHeight: widget.buttonHeight,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
