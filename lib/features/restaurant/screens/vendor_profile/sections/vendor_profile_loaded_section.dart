import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/sections/vendor_about_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/agreement/sections/vendor_agreement_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/sections/vendor_menu_preview_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/sections/vendor_tablet_profile_header.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_cover_header.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_info_block.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_profile_tab_bar.dart';
import 'package:halalhub_restaurant/features/restaurant/utils/vendor_profile_formatting.dart';

/// Tab / kategoriya holati — mahalliy UI (blocdan faqat [vendor] keladi).
mixin VendorProfileTabMixin on State<VendorProfileLoadedSection> {
  int selectedTab = 0;
  int? selectedCategoryId;

  void selectTab(int index) => setState(() => selectedTab = index);

  void selectCategory(int? id) => setState(() => selectedCategoryId = id);
}

class VendorProfileLoadedSection extends StatefulWidget {
  const VendorProfileLoadedSection({super.key, required this.vendor, required this.isTablet});

  final VendorMeModel vendor;
  final bool isTablet;

  @override
  State<VendorProfileLoadedSection> createState() => _VendorProfileLoadedSectionState();
}

class _VendorProfileLoadedSectionState extends State<VendorProfileLoadedSection> with VendorProfileTabMixin {
  Future<void> _onRefresh() async {
    final bloc = context.read<VendorProfileBloc>();
    bloc.add(const VendorProfileRequested());
    await bloc.stream.firstWhere((state) => state is VendorProfileLoaded || state is VendorProfileFailure);
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.sizeOf(context).width;
    final v = widget.vendor;
    final logoUrl = effectiveImageUrl(v.logoUrl, v.logo);
    final coverUrl = effectiveImageUrl(v.coverUrl, v.coverImage);
    final today = workdayForToday(v.workdays);
    final workLine = formatWorkdayLine(today);

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final layoutW = constraints.maxWidth;

          if (widget.isTablet) {
            final hPad = context.wOf(20, layoutW);
            if (selectedTab == 0) {
              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: VendorTabletProfileHeader(vendor: v, workLine: workLine, layoutWidth: layoutW),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: context.wOf(8, layoutW))),
                    SliverToBoxAdapter(
                      child: VendorProfileTabBar(selected: selectedTab, onChanged: selectTab),
                    ),
                  ],
                  body: Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                    child: VendorMenuPreviewSection(
                      vendorId: v.id,
                      selectedCategoryId: selectedCategoryId,
                      onCategorySelected: selectCategory,
                      maxWidth: layoutW, //
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: VendorTabletProfileHeader(vendor: v, workLine: workLine, layoutWidth: layoutW),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: context.wOf(8, layoutW))),
                  SliverToBoxAdapter(
                    child: VendorProfileTabBar(selected: selectedTab, onChanged: selectTab),
                  ),
                  if (selectedTab == 0)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                        child: VendorMenuPreviewSection(vendorId: v.id, selectedCategoryId: selectedCategoryId, onCategorySelected: selectCategory, maxWidth: layoutW),
                      ),
                    )
                  else if (selectedTab == 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, context.wOf(24, layoutW)),
                        child: VendorAboutSection(vendor: v, maxWidth: layoutW),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, context.wOf(24, layoutW)),
                        child: VendorAgreementSection(vendorId: v.id ?? 0, maxWidth: layoutW),
                      ),
                    ),
                ],
              ),
            );
          }

          final maxW = screenW;
          final cardPad = context.wOf(16, maxW);
          if (selectedTab == 0) {
            return Align(
              alignment: Alignment.topCenter,
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: NestedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: VendorCoverHeader(
                        coverUrl: coverUrl,
                        logoUrl: logoUrl,
                        isTablet: false,
                        maxWidth: maxW,
                        onLogoTap: () => context.router.push(
                          const VendorAccountMenuRoute(), //
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: cardPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            VendorInfoBlock(vendor: v, workLine: workLine, maxWidth: maxW),
                            const SizedBox(height: 12),
                            CustomButton(
                              label: TranslationKeys.editProfile.tr(context: context),
                              onPressed: () async {
                                final updated = await context.router.push<bool>(const UpdateRestaurantRoute());
                                if (updated == true && context.mounted) {
                                  context.read<VendorProfileBloc>().add(const VendorProfileRequested());
                                }
                              },
                              backgroundColor: StaticColors.primary,
                              foregroundColor: StaticColors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: context.wOf(16, maxW))),
                    SliverToBoxAdapter(
                      child: VendorProfileTabBar(selected: selectedTab, onChanged: selectTab),
                    ),
                  ],
                  body: Padding(
                    padding: EdgeInsets.symmetric(horizontal: cardPad, vertical: 12),
                    child: VendorMenuPreviewSection(
                      vendorId: v.id,
                      selectedCategoryId: selectedCategoryId,
                      onCategorySelected: selectCategory,
                      maxWidth: maxW, //
                    ),
                  ),
                ),
              ),
            );
          }
          return Align(
            alignment: Alignment.topCenter,
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: VendorCoverHeader(
                      coverUrl: coverUrl,
                      logoUrl: logoUrl,
                      isTablet: false,
                      maxWidth: maxW,
                      onLogoTap: () => context.router.push(
                        const VendorAccountMenuRoute(), //
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: cardPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          VendorInfoBlock(vendor: v, workLine: workLine, maxWidth: maxW),
                          const SizedBox(height: 12),
                          CustomButton(
                            label: TranslationKeys.editProfile.tr(context: context),
                            onPressed: () async {
                              final updated = await context.router.push<bool>(const UpdateRestaurantRoute());
                              if (updated == true && context.mounted) {
                                context.read<VendorProfileBloc>().add(const VendorProfileRequested());
                              }
                            },
                            backgroundColor: StaticColors.primary,
                            foregroundColor: StaticColors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: context.wOf(16, maxW))),
                  SliverToBoxAdapter(
                    child: VendorProfileTabBar(selected: selectedTab, onChanged: selectTab),
                  ),
                  if (selectedTab == 0)
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: cardPad, vertical: 12),
                        child: VendorMenuPreviewSection(
                          vendorId: v.id,
                          selectedCategoryId: selectedCategoryId,
                          onCategorySelected: selectCategory,
                          maxWidth: maxW, //
                        ),
                      ),
                    )
                  else if (selectedTab == 1)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(cardPad, 12, cardPad, cardPad),
                        child: VendorAboutSection(vendor: v, maxWidth: maxW),
                      ),
                    )
                  else
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(cardPad, 12, cardPad, cardPad),
                        child: VendorAgreementSection(vendorId: v.id ?? 0, maxWidth: maxW),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
